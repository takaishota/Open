//
//  SplitViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/16.
//

#import "SplitViewController.h"
#import "AuthViewController.h"
#import "KxSMBProvider.h"
#import "FileViewController.h"
#import "OPNUserEntry.h"
#import "TreeViewController.h"
#import "ServerListViewController.h"

@interface SplitViewController () <AuthViewControllerDelegate, KxSMBProviderDelegate, TreeViewControllerDelegate, ServerListViewControllerDelegate>
@property (nonatomic) ServerListViewController *rootTreeViewController;
@property (nonatomic) UINavigationController *navigationControllerForMaster;
@property (nonatomic) UINavigationController *navigationControllerForDetail;
@end

@implementation SplitViewController {
    NSMutableDictionary *_cachedAuths;
    AuthViewController *_authViewController;
}

#pragma mark - Lifecycle
- (id)init {
    
    self = [super init];
    if (self) {
        
        self.rootTreeViewController = [ServerListViewController new];
        self.rootTreeViewController.delegate = self;
        self.navigationControllerForMaster = [[UINavigationController alloc] initWithRootViewController:self.rootTreeViewController];

        // detailViewControllerの生成
        FileViewController *fileViewController = [FileViewController new];
        self.navigationControllerForDetail = [[UINavigationController alloc] initWithRootViewController:fileViewController];
        
        self.viewControllers = @[self.navigationControllerForMaster, self.navigationControllerForDetail];
        
        //キャッシュの初期化
        _cachedAuths = [NSMutableDictionary dictionary];
        
        // SMBProviderを生成し、デリゲートを設定する
        KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
        provider.delegate = self;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void) presentAuthViewControllerForServer: (NSString *) server
{
    if (!_authViewController) {
        _authViewController = [[AuthViewController alloc] init];
        _authViewController.delegate = self;
        _authViewController.username = [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
        _authViewController.remoteDir = [[NSUserDefaults standardUserDefaults] stringForKey:@"RemoteDirectory"];
        _authViewController.password = [[NSUserDefaults standardUserDefaults] stringForKey:@"Password"];
        _authViewController.workgroup = [[NSUserDefaults standardUserDefaults] stringForKey:@"Workgroup"];
    }
    
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    if (nav.presentedViewController)
        return;
    
    _authViewController.server = server;
    [self couldAuthViewController:_authViewController];
    
}

#pragma mark - TreeViewControllerDelegate
- (void) pushMasterViewController:(KxSMBItem*)item {
    TreeViewController *vc = [[TreeViewController alloc] init];
    vc.path = item.path;
    vc.delegate = self;
    [self.navigationControllerForMaster pushViewController:vc animated:YES];
}

- (void) pushDetailViewController:(KxSMBItem*)item {
    FileViewController *vc = [[FileViewController alloc] init];
    vc.smbFile = (KxSMBItemFile *)item;
    [self.navigationControllerForDetail pushViewController:vc animated:YES];
}

#pragma mark - ServerListViewContollerDelegate
- (void)pushMasterViewControllerBySelectedEntries:(OPNUserEntry *)entry {
    TreeViewController *vc = [[TreeViewController alloc] init];
    
    NSString *entryPath = entry.targetServer.ip;
    if (entry.remoteDirectory) {
        entryPath = [entryPath stringByAppendingString:entry.remoteDirectory];
    }
    vc.path = entryPath;
    vc.delegate = self;
    [self.navigationControllerForMaster pushViewController:vc animated:YES];
    
    _cachedAuths = [NSMutableDictionary dictionary];
    
    [vc reloadPath];
}

#pragma mark - AuthViewControllerDelegate
- (void) couldAuthViewController: (AuthViewController *) controller {
    // ユーザデフォルトから認証情報を取得してセットする
    KxSMBAuth *auth = [KxSMBAuth smbAuthWorkgroup:[[NSUserDefaults standardUserDefaults] stringForKey:@"Workgroup"]
                                         username:[[NSUserDefaults standardUserDefaults] stringForKey:@"Username"]
                                         password:[[NSUserDefaults standardUserDefaults] stringForKey:@"Password"]];
    
    if (controller) {
        _cachedAuths[controller.server.uppercaseString] = auth;
    }
    
    NSLog(@"store auth for %@ -> %@/%@:%@",
          controller.server, auth.workgroup, auth.username, auth.password);
    
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [nav dismissViewControllerAnimated:YES completion:nil];
    
//    [self.navigationControllerForMaster.viewControllers[0] reloadPath];
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

@end
