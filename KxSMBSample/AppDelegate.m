//
//  AppDelegate.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//

#import "AppDelegate.h"
// :: Other ::
#import "AuthViewController.h"
#import "FileViewController.h"
#import "KxSMBProvider.h"
#import "TreeViewController.h"

@interface AppDelegate() <KxSMBProviderDelegate, AuthViewControllerDelegate, TreeViewControllerDelegate>
@end

@implementation AppDelegate {

    TreeViewController *_headVC;
    NSMutableDictionary *_cachedAuths;
    AuthViewController *_authViewController;
}

#pragma mark - ViewController LifeCycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // split Viewの生成
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    
    // メニュー用ViewControllerの生成
    _headVC = [[TreeViewController alloc] initAsHeadViewController];
    _headVC.splitViewController = splitViewController;
    UINavigationController *treeNavigationViewController = [[UINavigationController alloc] initWithRootViewController:_headVC];
    [splitViewController addChildViewController:treeNavigationViewController];
    _headVC.delegate = self;
    
    // 詳細用ViewControllerの生成
    FileViewController *fileViewController = [[FileViewController alloc] init];
    UINavigationController *fileNavigationViewController = [[UINavigationController alloc] initWithRootViewController:fileViewController];
    [splitViewController addChildViewController:fileNavigationViewController];
    _headVC.fileViewNavigationController = fileNavigationViewController;
    fileViewController.splitViewController = splitViewController;
    
    splitViewController.delegate = fileViewController;
    
    // windowのrootViewControllerとしてSplitViewControllerを設定
    self.window.rootViewController = splitViewController;
    
    //キャッシュの初期化
    _cachedAuths = [NSMutableDictionary dictionary];
    
    // SMBProviderを生成し、デリゲートを設定する
    KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
    provider.delegate = self;
    
    // 内容を表示する
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark - private method

- (void) presentAuthViewControllerForServer: (NSString *) server
{
    if (!_authViewController) {
        _authViewController = [[AuthViewController alloc] init];
        _authViewController.delegate = self;
        _authViewController.username = [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
        _authViewController.localDir = [[NSUserDefaults standardUserDefaults] stringForKey:@"RemoteDirectory"];
        _authViewController.password = [[NSUserDefaults standardUserDefaults] stringForKey:@"Password"];
        _authViewController.workgroup = [[NSUserDefaults standardUserDefaults] stringForKey:@"Workgroup"];
    }
    
    
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    
    if (nav.presentedViewController)
        return;
    
    _authViewController.server = server;
    [self couldAuthViewController:_authViewController done:YES];
    
}

#pragma mark - KxSMBProviderDelegate

- (KxSMBAuth *) smbAuthForServer: (NSString *) server
                       withShare: (NSString *) share
{
    // キャッシュがセットされている場合はキャッシュを返す
    KxSMBAuth *auth = _cachedAuths[server.uppercaseString];
    if (auth)
        return auth;
    
    // セットされていない場合は認証画面を呼び出して何もしない
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self presentAuthViewControllerForServer:server];
    });
    
    return nil;
}

#pragma mark - TreeViewControllerDelegate
- (void) authViewCloseHandler:(AuthViewController*)controller {
    
    // キャッシュを初期化する
    _cachedAuths = [NSMutableDictionary dictionary];
    
    [self couldAuthViewController:controller done:YES];
}

#pragma mark - AuthViewControllerDelegate
- (void) couldAuthViewController: (AuthViewController *) controller
                               done: (BOOL) done
{
    if (done) {
        
        // ユーザデフォルトから認証情報を取得してセットする
        KxSMBAuth *auth = [KxSMBAuth smbAuthWorkgroup:[[NSUserDefaults standardUserDefaults] stringForKey:@"Workgroup"]
                                             username:[[NSUserDefaults standardUserDefaults] stringForKey:@"Username"]
                                             password:[[NSUserDefaults standardUserDefaults] stringForKey:@"Password"]];
        
        _cachedAuths[controller.server.uppercaseString] = auth;
        
        NSLog(@"store auth for %@ -> %@/%@:%@",
              controller.server, auth.workgroup, auth.username, auth.password);
    }
    
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    [nav dismissViewControllerAnimated:YES completion:nil];
    
    [_headVC reloadPath];
}



@end
