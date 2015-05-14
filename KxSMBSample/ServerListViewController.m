//
//  ServerListViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/20.
//

#import "ServerListViewController.h"
// :: Other ::
#import "AuthViewController.h"
#import "DataLoader.h"
#import "LoginStatusManager.h"
#import "OPNUserEntry.h"
#import "OPNUserEntryManager.h"
#import "Server.h"
#import "ServerListCell.h"

static NSString * const kCellIdentifier = @"cellIdentifier";

@interface ServerListViewController () <AuthViewControllerDelegate, UITextFieldDelegate>
@property (nonatomic) DataLoader   *dataLoader;
@property (nonatomic) NSArray      *userEntries;
@property (nonatomic) OPNUserEntry *selectedUserEntry;
@property (nonatomic) OPNUserEntry *editingUserEntry;
@end

@implementation ServerListViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(presentUserEntryAddView)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
UIBarButtonSystemItemTrash
                                                                                          target:self
                                                                                          action:@selector(removeAllEntries)];
    
    self.navigationItem.title = @"サーバ一覧";
    self.userEntries = [OPNUserEntryManager sharedManager].userEntries;
    
    [self setTableViewStyle];
    [self.tableView registerClass:[ServerListCell class] forCellReuseIdentifier:@"cellIdentifier"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

- (void)didPushEditButton:(UIButton*)sender event:(UIEvent*)event {
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    self.editingUserEntry = [OPNUserEntryManager sharedManager].userEntries[indexPath.row];
    [self presentUserEntryEditViewAtIndex:indexPath.row];
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
    ServerListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = (ServerListCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.text = [[OPNUserEntryManager sharedManager] getServerIpAtIndex:indexPath.row];
    UIImage *img = [UIImage imageNamed:@"mac"];
    cell.imageView.image = img;
    [(UIButton*)cell.accessoryView addTarget:self action:@selector(didPushEditButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
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
    [self connectServer];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[OPNUserEntryManager sharedManager] removeUserEntry:indexPath.row];
        [self.tableView reloadData];
    }
}

#pragma mark - Auth View Controller Delegate
- (void)reload {
    self.userEntries = [OPNUserEntryManager sharedManager].userEntries;
    [self.tableView reloadData];
}

#pragma mark - Bar Button Item Event Handler
- (void)presentUserEntryAddView {
    AuthViewController *vc = [[AuthViewController alloc] init];
    vc.userEntry = nil;
    
    // split view controller にdelegateする
    [self.navigationController pushViewController:vc animated:YES];
    vc.delegate = self;
}

- (void)presentUserEntryEditViewAtIndex:(NSUInteger)index {
    // 編集の場合は指定されたindexのエントリ情報をユーザデフォルトから取得してセットする
    // ユーザデフォルトのエントリ配列を取り出して設定する
    OPNUserEntry *userEntry = [OPNUserEntryManager sharedManager].userEntries[index];
    AuthViewController *vc = [[AuthViewController alloc] initWithUserEntry:userEntry];
    
    // split view controller にdelegateする
    [self.navigationController pushViewController:vc animated:YES];
    vc.delegate = self;
}

- (void)removeAllEntries {
    [[OPNUserEntryManager sharedManager] removeAllUserEntries];
    [self reload];
}

- (void)connectServer {
    // 接続処理を行う
    [self connect];
    
    if ([self.delegate respondsToSelector:@selector(pushMasterViewControllerBySelectedEntry:)]) {
        [self.delegate pushMasterViewControllerBySelectedEntry:self.selectedUserEntry];
    }
}

- (void)connect {
    NSError *error = nil;
    if (error) {
        // エラーメッセージ
    }
    [OPNUserEntryManager sharedManager].lastUserEntry = self.selectedUserEntry;
    [LoginStatusManager sharedManager].isLaunchedApp = NO;
}

- (void)setTableViewStyle {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight       = 70.f;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ServerListViewController description:\n%@ delegate: %@\n",[super description], self.delegate];
}

@end
