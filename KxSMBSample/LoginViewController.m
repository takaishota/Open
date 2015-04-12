//
//  LoginViewController.m
//  SMBFileReader
//
//  Created by ShotaTakai on 2015/04/12.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"LoginViewController %s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//
//- (void)didPushShowPopupButton {
//    [self.view endEditing:YES];
//    
//    self.popupViewController = [PopupViewController new];
//    self.popupViewController.delegate = self;
//    [self setUpPopoverViewController:self.popupViewController];
//    [self.popupViewController showPopupView:CGPointMake(CGRectGetMidX(self.btn.frame), CGRectGetMaxY(self.btn.frame) + 5)];
//}
//
//- (void) dismissPopupView {
//    [self removePopupViewController:self.popupViewController];
//}
//
//- (void)setUpPopoverViewController:(UIViewController*)viewController {
//    [self addChildViewController:viewController];
//    [self.view addSubview:viewController.view];
//    [viewController didMoveToParentViewController:self];
//}
//
//- (void)removePopupViewController:(UIViewController*)viewController
//{
//    [viewController willMoveToParentViewController:nil];
//    [viewController.view removeFromSuperview];
//    [viewController removeFromParentViewController];
//}

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

@end
