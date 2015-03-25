//
//  TreeViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//


#import <UIKit/UIKit.h>

@interface TreeViewController : UITableViewController
- (id)initAsHeadViewController;
- (void) reloadPath;
@property (readwrite, nonatomic, strong) NSString *path;
@property (nonatomic, strong) UINavigationController *fileViewNavigationController;
@end
