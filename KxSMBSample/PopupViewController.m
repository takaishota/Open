//
//  PopupViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/06.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import "PopupViewController.h"
#import "AuthViewController.h"
#import "DataLoader.h"
#import "DXPopover.h"
#import "Server.h"
#import "ServerListCell.h"

@interface PopupViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) DXPopover *popover;
@property (nonatomic) DataLoader *dataLoader;
@property (nonatomic) Server *selectedServer;
@end

@implementation PopupViewController {
    CGFloat _popoverWidth;
    Server *_selectedSerever;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupServerList];
}

- (void) setupServerList {
    self.dataLoader = [[DataLoader alloc] initWithJSONFile:@"servers.json"];
    
    UITableView *serverListView    = [[UITableView alloc] init];
    serverListView.frame           = CGRectMake(0, 0, _popoverWidth, 160);
    serverListView.dataSource      = self;
    serverListView.delegate        = self;
    self.tableView                 = serverListView;
    self.tableView.rowHeight       = 50;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[ServerListCell class] forCellReuseIdentifier:cellId];
    [self resetPopover];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static NSString *cellId = @"cellIdentifier";
- (void)resetPopover {
    self.popover  = [DXPopover new];
    _popoverWidth = CGRectGetWidth(self.parentViewController.view.bounds);
}

- (void)showPopupView:(CGPoint)point {
    [self updateTableViewFrame];
    [self.popover showAtPoint:point popoverPostion:DXPopoverPositionDown withContentView:self.tableView inView:self.view];
    PopupViewController __weak *tmp = self;
    tmp.popover.didDismissHandler = ^{
        if ([self.delegate respondsToSelector:@selector(dismissPopupView)]) {
            [self.delegate dismissPopupView];
        }
    };
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.dataLoader.serverList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = (ServerListCell*)[[ServerListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.separatorInset = UIEdgeInsetsZero;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell && [cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    Server *server = self.dataLoader.serverList[indexPath.row];
    
    cell.textLabel.text = server.ip;
    if ([_selectedSerever.ip isEqualToString:server.ip]) {
        cell.textLabel.textColor = self.view.tintColor;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    UIImage *img;
    if ([server.networkType isEqualToString:@"LAN"]) {
        img = [UIImage imageNamed:@"mac.png"];
    } else if ([server.networkType isEqualToString:@"CLOUD"]) {
        img = [UIImage imageNamed:@"cloud.png"];
    } else if ([server.networkType isEqualToString:@"PUBLIC"]) {
        img = [UIImage imageNamed:@"public.png"];
    }
    cell.imageView.image = img;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO:テキストフィールドに値をセットする
    
    // 選択中のサーバーを保持する
    _selectedSerever = self.dataLoader.serverList[indexPath.row];
    [self.popover dismiss];
    if ([self.delegate respondsToSelector:@selector(dismissPopupView)]) {
        [self.delegate dismissPopupView];
    }
    
}

- (void)updateTableViewFrame
{
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.width = _popoverWidth;
    self.tableView.frame = tableViewFrame;
}

- (void)bounceTargetView:(UIView *)targetView
{
    targetView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        targetView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (NSString*)getSelectedServer {
    return _selectedSerever.ip;
}

@end