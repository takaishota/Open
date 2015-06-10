//
//  AuthViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/19.
//

#import <UIKit/UIKit.h>
@class OPNUserEntry;
@class Server;
@class AuthViewController;

@protocol AuthViewControllerDelegate <NSObject>
@optional
- (void) reload;
@end

@interface AuthViewController : UIViewController
@property (nonatomic, weak)id <AuthViewControllerDelegate>delegate;
@property (nonatomic) NSString *entryName;
@property (nonatomic) NSString *remoteDirectory;
@property (nonatomic) NSString *workgroup;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *password;
@property (nonatomic) Server *targetServer;
@property (nonatomic) OPNUserEntry *userEntry;
@property (nonatomic) NSUInteger selectedEntryIndex;

- (id)initWithUserEntry:(OPNUserEntry*)userEntry;

@end
