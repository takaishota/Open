//
//  TreeViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//


#import <UIKit/UIKit.h>
@class TreeViewController, AuthViewController;

@protocol TreeViewControllerDelegate <NSObject>
@optional
- (void)authViewCloseHandler:(AuthViewController*)controller;
- (void)pushDetailViewController:(UIViewController*)viewController;
@end

@interface TreeViewController : UITableViewController
- (id)initAsHeadViewController;
- (void) reloadPath;

@property (nonatomic, weak) id delegate;
@property (readwrite, nonatomic, strong) NSString *path;
@property (nonatomic, strong) UINavigationController *fileViewNavigationController;
@property (nonatomic) UIBarButtonItem *fileViewleftBarButton;
@end
