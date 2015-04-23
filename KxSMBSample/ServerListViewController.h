//
//  ServerListViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/20.
//

#import <UIKit/UIKit.h>
@class ServerListViewControllerDelegate;

@protocol ServerListViewControllerDelegate <NSObject>
@optional
- (void)pushMasterViewControllerBySelectedServer:(NSString*)server;
@end

@interface ServerListViewController : UITableViewController
@property (nonatomic) id <ServerListViewControllerDelegate> delegate;
@end
