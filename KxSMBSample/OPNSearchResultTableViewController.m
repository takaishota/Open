//
//  OPNSearchResultTableViewController.m
//  OPNFileReader
//
//  Created by Shota Takai on 2015/05/28.
//  Copyright (c) 2015年 NRI Netcom. All rights reserved.
//

#import "OPNSearchResultTableViewController.h"
#import "UIColor+CustomColors.h"
#import "KxSMBProvider.h"

@implementation OPNSearchResultTableViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTableViewStyle];
}

- (void)setTableViewStyle {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 70.f;
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    [self setupCell:cell WithItem:self.searchResults[indexPath.row]];
    
    return cell;
}

- (void)setupCell:(UITableViewCell*)cell WithItem:(KxSMBItem*)item {
    UIImage *image = nil;
    NSString *fileSize = @"";
    NSString *timeStamp = @"";
    if ([item isKindOfClass:[KxSMBItemTree class]]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        image = [UIImage imageNamed:@"folder.png"];
        cell.imageView.tintColor = [UIColor colorWithRed:0.94 green:0.86 blue:0.74 alpha:1];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        fileSize = [NSString stringWithFormat:@"%ld KB", item.stat.size / 1000];
        timeStamp = [NSString stringWithFormat:@"%@", item.stat.lastModified];
        image = [UIImage imageNamed:@"file.png"];
        cell.imageView.tintColor = [UIColor colorWithRed:0.93 green:0.94 blue:0.95 alpha:1];
    }
    if (timeStamp.length) {
        timeStamp = [timeStamp substringToIndex:16];
    }
    
    cell.textLabel.text = item.path.lastPathComponent;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    
    cell.detailTextLabel.textColor = [UIColor customGrayColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@     %@", timeStamp, fileSize];
    cell.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    KxSMBItem *item = self.searchResults[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(searchResultView:didSelectItem:)]) {
        [self.delegate searchResultView:self didSelectItem:item];
    }
    
}
@end
