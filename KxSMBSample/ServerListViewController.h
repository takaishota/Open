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
@property (nonatomic) NSString *serverPath;
@property (nonatomic) NSString *remoteDirectory;
@property (nonatomic) NSString *workgroup;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *password;
@end
