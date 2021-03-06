//
//  TreeViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//


#import <UIKit/UIKit.h>
@class TreeViewController, AuthViewController, KxSMBItem;

@protocol TreeViewControllerDelegate <NSObject>
@optional
- (void)pushMasterViewController:(KxSMBItem*)item;
- (void)pushDetailViewController:(KxSMBItem*)item;
@end

@interface TreeViewController : UITableViewController

@property (nonatomic, weak) id <TreeViewControllerDelegate> delegate;
@property (readwrite, nonatomic, strong) NSString *path;
@end
