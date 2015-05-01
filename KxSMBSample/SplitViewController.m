//
//  SplitViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/16.
//

#import "SplitViewController.h"
// :: Other ::
#import "AuthViewController.h"
#import "FileViewController.h"
#import "KxSMBProvider.h"
#import "OPNUserEntry.h"
#import "ServerListViewController.h"
#import "TreeViewController.h"

@interface SplitViewController () <AuthViewControllerDelegate, KxSMBProviderDelegate, TreeViewControllerDelegate, ServerListViewControllerDelegate, FileViewControllerDelegate>
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
        
        self.rootTreeViewController            = [ServerListViewController new];
        self.rootTreeViewController.delegate   = self;
        self.navigationControllerForMaster     = [[UINavigationController alloc] initWithRootViewController:self.rootTreeViewController];

        // detailViewControllerの生成
        FileViewController *fileViewController = [FileViewController new];
        fileViewController.delegate            = self;
        self.navigationControllerForDetail     = [[UINavigationController alloc] initWithRootViewController:fileViewController];

        self.viewControllers                   = @[self.navigationControllerForMaster, self.navigationControllerForDetail];

        //キャッシュの初期化
        _cachedAuths                           = [NSMutableDictionary dictionary];

        // SMBProviderを生成し、デリゲートを設定する
        KxSMBProvider *provider                = [KxSMBProvider sharedSmbProvider];
        provider.delegate                      = self;
        
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
        _authViewController           = [[AuthViewController alloc] init];
        _authViewController.delegate  = self;
        _authViewController.username  = [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
        _authViewController.remoteDir = [[NSUserDefaults standardUserDefaults] stringForKey:@"RemoteDirectory"];
        _authViewController.password  = [[NSUserDefaults standardUserDefaults] stringForKey:@"Password"];
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
    vc.path                = item.path;
    vc.delegate            = self;
    [self.navigationControllerForMaster pushViewController:vc animated:YES];
}

- (void) pushDetailViewController:(KxSMBItem*)item {
    FileViewController *vc = [[FileViewController alloc] init];
    vc.smbFile             = (KxSMBItemFile *)item;
    vc.delegate            = self;

    [self.navigationControllerForDetail pushViewController:vc animated:YES];
}

#pragma mark - ServerListViewContollerDelegate
- (void)pushMasterViewControllerBySelectedEntry:(OPNUserEntry *)entry {
    TreeViewController *vc = [[TreeViewController alloc] init];

    NSString *entryPath    = entry.targetServer.ip;
    if (entry.remoteDirectory) {
    entryPath              = [entryPath stringByAppendingString:entry.remoteDirectory];
    }
    vc.path                = entryPath;
    vc.delegate            = self;
    [self.navigationControllerForMaster pushViewController:vc animated:YES];

    _cachedAuths           = [NSMutableDictionary dictionary];
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
    
}

#pragma mark - File View Controller Delegate
- (void) hideTreeView:(BOOL)isHidden {
    isHidden = !isHidden;
    
    // FIXME:回転時にViewの位置、サイズがおかしい
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
        [UIView animateWithDuration:0.2f animations:^{
            self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
        } completion:^(BOOL finished) {
            self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
        }];
    }else {
        CGFloat xOffset       = 320.0f;
        CGFloat fileViewWidth = 480;
        [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if (isHidden) {
                self.view.frame = CGRectMake(0,
                                             0,
                                             [[UIScreen mainScreen] applicationFrame].size.width,
                                             [[UIScreen mainScreen] applicationFrame].size.height);
                self.navigationControllerForDetail.view.frame = CGRectMake(xOffset,
                                                                           0,
                                                                           fileViewWidth,
                                                                           self.view.frame.size.height);
            } else {
                self.view.frame = CGRectMake(-xOffset,
                                             0,
                                             self.view.frame.size.width + xOffset,
                                             self.view.frame.size.height);
                self.navigationControllerForDetail.view.frame = CGRectMake(0,
                                                                           0,
                                                                           [[UIScreen mainScreen] applicationFrame].size.width,
                                                                           self.view.frame.size.height);
            }
        } completion:^ (BOOL finished){
            // 完了時のコールバック
            NSLog(@"finish Animation");
        }];
    }
}

#pragma mark - KxSMBProviderDelegate

- (KxSMBAuth *) smbAuthForServer: (NSString *) server
                       withShare: (NSString *) share
{
    // キャッシュがセットされている場合はキャッシュを返す
    KxSMBAuth *auth = _cachedAuths[server.uppercaseString];
    if (auth) {
        return auth;
    }
    // セットされていない場合は認証画面を呼び出して何もしない
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentAuthViewControllerForServer:server];
    });
    
    return nil;
}

@end
