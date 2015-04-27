//
//  ServerListViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/20.
//

#import "ServerListViewController.h"
#import "AuthViewController.h"
#import "DataLoader.h"
#import "LoginStatusManager.h"
#import "Server.h"
#import "ServerListCell.h"
#import "OPNUserEntryManager.h"
#import "OPNUserEntry.h"

static NSString * const kCellIdentifier = @"cellIdentifier";

@interface ServerListViewController () <AuthViewControllerDelegate, UITextFieldDelegate>
@property (nonatomic) DataLoader *dataLoader;
@property (nonatomic) NSArray *userEntries;
@property (nonatomic) OPNUserEntry *selectedUserEntry;
@end

@implementation ServerListViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addAuthView)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
UIBarButtonSystemItemTrash
                                                                                          target:self
                                                                                          action:@selector(removeAllEntries)];
    
    NSLog(@"%s :dictionaryRepresentation: %@", __FUNCTION__,[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    self.navigationItem.title = @"サーバ一覧";
    self.userEntries = [OPNUserEntryManager sharedManager].userEntries;
    
    [self setTableViewStyle];
    [self.tableView registerClass:[ServerListCell class] forCellReuseIdentifier:@"cellIdentifier"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.userEntries count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.text = [[OPNUserEntryManager sharedManager] getServerIpAtIndex:indexPath.row];
    UIImage *img = [UIImage imageNamed:@"mac"];
    cell.imageView.image = img;
    
    return cell;
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.delegate) {
        return;
    }
    self.selectedUserEntry = [OPNUserEntryManager sharedManager].userEntries[indexPath.row];
    if (!self.selectedUserEntry) {
        return;
    }
    
    [self showLoginViewController:self.selectedUserEntry];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert;
}

#pragma mark - Auth View Controller Delegate
- (void) reload {
    self.userEntries = [OPNUserEntryManager sharedManager].userEntries;
    [self.tableView reloadData];
}

#pragma mark - Bar Button Item Event Handler
- (void) addAuthView {
    AuthViewController *vc = [[AuthViewController alloc] init];
    
    // split view controller にdelegateする
    [self.navigationController pushViewController:vc animated:YES];
    vc.delegate = self;
}

- (void) removeAllEntries {
    [[OPNUserEntryManager sharedManager] removeAllUserEntries];
    [self reload];
}

#pragma mark - Private
- (void)showLoginViewController:(OPNUserEntry*)entry {
    
    // 認証ダイアログを表示する
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS 8の時の処理
        UIAlertController *alertController = [self generateAlertController];
        alertController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:alertController animated:YES completion:nil];
    }else {
        // iOS 7以前の処理
        UIAlertView *alert = [self generateAlertView];
        [alert show];
    }
}

- (UIAlertController *)generateAlertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ログイン"
                                                                             message:@"ログイン情報を入力してください"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // TODO:設定画面で前回の値を使うかON/OFFできるようにする
    BOOL isAvailableLastLoginSetting = NO;
    if (!isAvailableLastLoginSetting) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"ユーザネーム";
            [self formatTextField:textField];
            textField.delegate    = self;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"パスワード";
            textField.secureTextEntry = true;
            [self formatTextField:textField];
        }];
    }
    
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect = self.view.bounds;
    alertController.popoverPresentationController.permittedArrowDirections = 0;
    [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // キャンセルボタンが押された時の処理
        [self cancelButtonDidPushed];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"ログイン" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // ログインボタンが押された時の処理
        [self loginButtonDidPushed];
    }]];
    return alertController;
}

- (UIAlertView *)generateAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ログイン"
                                                        message:@"ログイン情報を入力してください"
                                                       delegate:self
                                              cancelButtonTitle:@"キャンセル"
                                              otherButtonTitles:@"ログイン", nil];
    // TODO:iOS7以下の処理
    
    return alertView;
}
- (void)formatTextField:(UITextField *)textField {
    
}

- (void)loginButtonDidPushed {
    // 接続処理を行う
    [self connect:self.selectedUserEntry];
    
    // splitViewのpushメソッドを呼び出す
    if ([self.delegate respondsToSelector:@selector(pushMasterViewControllerBySelectedEntries:)]) {
        [self.delegate pushMasterViewControllerBySelectedEntries:self.selectedUserEntry];
    }
}

- (void)connect:(OPNUserEntry*)entry {
    NSError *error = nil;
    if (&error) {
        // エラーメッセージ
    }
    [LoginStatusManager sharedManager].isLaunchedApp = NO;
}
         
- (void)cancelButtonDidPushed {}

- (void)setTableViewStyle {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight       = 70.f;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"ServerListViewController description:\n%@ delegate: %@\n",[super description], self.delegate];
}

@end
