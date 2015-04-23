//
//  AuthViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/19.
//

#import <UIKit/UIKit.h>

@class AuthViewController;

@protocol AuthViewControllerDelegate <NSObject>
@optional
- (void) couldAuthViewController: (AuthViewController *) controller;
- (void) reload;
@end

@interface AuthViewController : UIViewController
@property (nonatomic, weak)id <AuthViewControllerDelegate>delegate;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *remoteDir;
@property (nonatomic, strong) NSString *workgroup;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end
