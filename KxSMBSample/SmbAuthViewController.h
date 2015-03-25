//
//  SmbAuthViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//


#import <UIKit/UIKit.h>

@class SmbAuthViewController;

@protocol SmbAuthViewControllerDelegate
@optional
- (void) couldSmbAuthViewController: (SmbAuthViewController *) controller
                               done: (BOOL) done;
@end

@interface SmbAuthViewController : UIViewController
@property (readwrite, nonatomic, weak) id delegate;
@property (readwrite, nonatomic, strong) NSString *server;
@property (readwrite, nonatomic, strong) NSString *workgroup;
@property (readwrite, nonatomic, strong) NSString *username;
@property (readwrite, nonatomic, strong) NSString *password;
@end
