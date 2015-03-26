//
//  LocalFileViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/26.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import "LocalFileViewController.h"
#import "FileUtility.h"

@interface LocalFileViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation LocalFileViewController {
    NSArray *_items;
    NSMutableArray* _datasource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ローカル";
    
    _items = [self getLocalFiles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)getLocalFiles {
    
    NSString *docPath = [[FileUtility sharedUtility] documentDirectory];
    NSArray *fileNames = [[FileUtility sharedUtility] fileNamesAtDirectoryPath:docPath extension:nil];
    _datasource = [fileNames mutableCopy];
    
    return _datasource;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
    }
    
    NSString *item = _items[indexPath.row];
    cell.textLabel.text = item;
    
//    if ([item isKindOfClass:[KxSMBItemTree class]]) {
//        
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.detailTextLabel.text =  @"";
//        
//    } else {
//        
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld KB", item.stat.size / 1000];
//    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    
    // ローカルファイルの削除
    FileUtility *utility = [FileUtility sharedUtility];
    BOOL result = [utility removeFileAtPath:[utility documentDirectoryWithFileName:_datasource[indexPath.row]]];
    if (!result) {
        // アラートを表示する
        NSLog(@"ファイルの削除に失敗しました");
        return;
    }
    [_datasource removeObjectAtIndex:indexPath.row];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
