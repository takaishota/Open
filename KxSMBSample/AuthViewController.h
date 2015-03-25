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
- (void) couldAuthViewController: (AuthViewController *) controller
                            done: (BOOL) done;
@end

@interface AuthViewController : UIViewController
@property (nonatomic, weak)id <AuthViewControllerDelegate>delegate;
@property (readwrite, nonatomic, strong) NSString *server;
@property (readwrite, nonatomic, strong) NSString *workgroup;
@property (readwrite, nonatomic, strong) NSString *username;
@property (readwrite, nonatomic, strong) NSString *password;

@end
