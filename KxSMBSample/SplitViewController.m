//
//  SplitViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/16.
//

#import "SplitViewController.h"
// :: Other ::
#import "AuthViewController.h"
#import "OPNFileDataController.h"
#import "OPNFileViewController.h"
#import "KxSMBProvider.h"
#import "OPNUserEntry.h"
#import "OPNUserEntryManager.h"
#import "Server.h"
#import "ServerListViewController.h"
#import "TreeViewController.h"

@interface SplitViewController () <KxSMBProviderDelegate, TreeViewControllerDelegate, ServerListViewControllerDelegate, OPNFileViewControllerDelegate>
@property (nonatomic) ServerListViewController *rootTreeViewController;
@property (nonatomic) UINavigationController   *navigationControllerForMaster;
@property (nonatomic) UINavigationController   *navigationControllerForDetail;
@end

@implementation SplitViewController {
    NSMutableDictionary *_cachedAuths;
    AuthViewController *_authViewController;
}

const float statusBarHeight = 20;

#pragma mark - Lifecycle
- (id)init {
    
    self = [super init];
    if (self) {
        
        self.rootTreeViewController            = [ServerListViewController new];
        self.rootTreeViewController.delegate   = self;
        self.navigationControllerForMaster     = [[UINavigationController alloc] initWithRootViewController:self.rootTreeViewController];

        // detailViewControllerの生成
        OPNFileViewController *fileViewController = [OPNFileViewController new];
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
- (void) presentAuthViewControllerForServer: (NSString *)server {
    if (!_authViewController) {
        _authViewController           = [[AuthViewController alloc] init];
        
        // TODO:エントリマネージャー経由で取得するようにする（ユーザデフォルトに直接アクセスしない）
        _authViewController.userName  = [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
        _authViewController.remoteDirectory = [[NSUserDefaults standardUserDefaults] stringForKey:@"RemoteDirectory"];
        _authViewController.password  = [[NSUserDefaults standardUserDefaults] stringForKey:@"Password"];
        _authViewController.workgroup = [[NSUserDefaults standardUserDefaults] stringForKey:@"Workgroup"];
    }
    
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    if (nav.presentedViewController)
        return;
    
    _authViewController.targetServer = [[Server alloc] initWithIp:server NetworkType:@"LAN"];
    [self couldAuthViewController:_authViewController];
    
}

#pragma mark - KxSMBProviderDelegate
- (KxSMBAuth *) smbAuthForServer: (NSString *) server
                       withShare: (NSString *) share {
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

#pragma mark - TreeViewControllerDelegate
- (void) pushMasterViewController:(KxSMBItem*)item {
    TreeViewController *vc = [[TreeViewController alloc] init];
    vc.path                = item.path;
    vc.delegate            = self;
    [self.navigationControllerForMaster pushViewController:vc animated:YES];
}

- (void) pushDetailViewController:(KxSMBItem*)item {
    OPNFileViewController *vc = [[OPNFileViewController alloc] init];
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
    
    // エントリマネージャから認証情報を取得してセットする
    KxSMBAuth *auth = [KxSMBAuth smbAuthWorkgroup:[OPNUserEntryManager sharedManager].lastUserEntry.workgroup
                                         username:[OPNUserEntryManager sharedManager].lastUserEntry.userName
                                         password:[OPNUserEntryManager sharedManager].lastUserEntry.password];

    if (controller) {
        _cachedAuths[controller.targetServer.ip.uppercaseString] = auth;
    }
    
    NSLog(@"store auth for %@ -> %@/%@:%@",
          controller.targetServer.ip, auth.workgroup, auth.username, auth.password);
    
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [nav dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - File View Controller Delegate
const CGFloat xOffset       = 320.0f;
- (void)showTreeView {
    // ポートレイトの場合は、SplitViewControllerのディスプレイモードを使う
    if ([[OPNFileDataController sharedInstance] isPortrait]) {
        [UIView animateWithDuration:0.2f animations:^{
            self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
        } completion:^(BOOL finished) {
            self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
        }];
    } else {
        [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.view.frame = CGRectMake(0,
                                         0,
                                         [[UIScreen mainScreen] applicationFrame].size.width,
                                         [[UIScreen mainScreen] applicationFrame].size.height + statusBarHeight);
            self.navigationControllerForDetail.view.frame = CGRectMake(xOffset,
                                                                       0,
                                                                       [[UIScreen mainScreen] applicationFrame].size.width - xOffset,
                                                                       self.view.frame.size.height);
        } completion:^ (BOOL finished){
            // 完了時のコールバック
            NSLog(@"finish Animation");
        }];
    }
}

- (void) hideTreeView {
    if ([[OPNFileDataController sharedInstance] isPortrait]) {
        [UIView animateWithDuration:0.2f animations:^{
            self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
        } completion:^(BOOL finished) {
            self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
        }];
    } else {
        [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.view.frame = CGRectMake(-xOffset,
                                             0,
                                             self.view.frame.size.width + xOffset,
                                             self.view.frame.size.height);
                self.navigationControllerForDetail.view.frame = CGRectMake(0,
                                                                           0,
                                                                           [[UIScreen mainScreen] applicationFrame].size.width,
                                                                           self.view.frame.size.height);
        } completion:^ (BOOL finished){
            // 完了時のコールバック
            NSLog(@"finish Animation");
        }];
    }
}

@end
