//
//  TreeViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//


#import <UIKit/UIKit.h>
@class TreeViewController, AuthViewController, SplitViewController, KxSMBItem;

@protocol TreeViewControllerDelegate <NSObject>
@optional
- (void)authViewCloseHandler:(AuthViewController*)controller;
- (void)pushMasterViewController:(KxSMBItem*)item;
- (void)pushDetailViewController:(KxSMBItem*)item;
@end

@interface TreeViewController : UITableViewController
- (id)initAsHeadViewController;
- (void) reloadPath;

@property (nonatomic, weak) id <TreeViewControllerDelegate> delegate;
@property (readwrite, nonatomic, strong) NSString *path;
@property (nonatomic, strong) UINavigationController *fileViewNavigationController;
@property (nonatomic) UIBarButtonItem *fileViewleftBarButton;
@end
