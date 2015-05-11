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
- (void) couldAuthViewController: (AuthViewController *) controller;
- (void) reload;
@end

@interface AuthViewController : UIViewController
@property (nonatomic, weak)id <AuthViewControllerDelegate>delegate;
@property (nonatomic) NSString *remoteDir;
@property (nonatomic) NSString *workgroup;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *password;
@property (nonatomic) Server *server;
@property (nonatomic) OPNUserEntry *userEntry;

- (id)initWithUserEntry:(OPNUserEntry*) userEntry;

@end
