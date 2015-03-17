//
//  RootViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/17.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import "RootViewController.h"
#import "TreeViewController.h"

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource>
@property NSArray *sectionList;
@end

@implementation RootViewController : UITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sectionList = @[@"ローカル", @"共有"];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionList count];
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionList[section];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!indexPath) {
        // ローカルファイルの一覧を表示する
    } else {
        // 共有サーバのディレクトリを表示する
        TreeViewController *vc = [[TreeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


@end
