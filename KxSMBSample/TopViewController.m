//
//  TopViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/09.
//

#import "TopViewController.h"
#import "AuthViewTextField.h"
#import "MLPSpotlight.h"
#import "PopupViewController.h"

@interface TopViewController () <UITextFieldDelegate, PopupViewDelegate>
@property (nonatomic) PopupViewController *popupViewController;
@property (nonatomic) UIButton *btn;
@property (nonatomic) UILabel *spotlightLabel;
@end

@implementation TopViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    self.view.backgroundColor = TOP_BACKGROUND_COLOR;
    [self.view setAlpha:0];
    [UIView animateWithDuration:0.2
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view setAlpha:1.0];
                     }completion:nil];
    
    const CGFloat labelWidth = 400;
    const CGFloat labelHeight = 100;
    
    self.spotlightLabel = [[UILabel alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2- labelWidth/2,
                                                                  [[UIScreen mainScreen] bounds].size.height/2 - 300,
                                                                  labelWidth,
                                                                  labelHeight)];
    self.spotlightLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    [self setFormatTitleLabel];
    [self.view addSubview:self.spotlightLabel];
    // TODO:サーバー選択フォームの表示
    // TODO:下からすっと出てくる
    const CGFloat W = 200;
    const CGFloat H = 40;
    
    const CGFloat X = [[UIScreen mainScreen] bounds].size.width/2 - W/2;
    const CGFloat Y = [[UIScreen mainScreen] bounds].size.height/2 - H/2;
    
    AuthViewTextField *textField = [AuthViewTextField new];
    textField.underLineColor = INFOCUS_UNDERLINE_COLOR;
    textField.enabled = NO;
    
    textField.backgroundColor = [UIColor clearColor];;
    textField.frame = CGRectMake(X, Y, W, H);
    [textField setTextFieldStyle];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    textField.text = [ud stringForKey:@"LastServer"];
    [textField setTextAlignment:NSTextAlignmentCenter];
    
    textField.delegate = self;
    [self.view addSubview:textField];
    
    [self setupPopupButton:(UIView*)textField];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginBtn.frame = CGRectMake(X, Y+H, W, H);
    loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [loginBtn setTitle:@"接続" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(didPushConnectButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    [MLPSpotlight addSpotlightInView:self.view atPoint:self.spotlightLabel.center];
            
}

#pragma mark - Private

- (void)setupPopupButton:(UIView*)superView {
    self.btn =[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.frame = superView.frame;
    self.btn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.btn];
    
    // PopupViewControllerをターゲットにする
    [self.btn addTarget:self action:@selector(didPushShowPopupButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setFormatTitleLabel {
    self.spotlightLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:48];
    self.spotlightLabel.backgroundColor = [UIColor clearColor];
    self.spotlightLabel.textColor       = [UIColor whiteColor];
}

- (void)didPushConnectButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

- (void)didPushShowPopupButton {
    [self.view endEditing:YES];
    
    self.popupViewController = [PopupViewController new];
    self.popupViewController.delegate = self;
    [self setUpPopoverViewController:self.popupViewController];
    [self.popupViewController showPopupView:CGPointMake(CGRectGetMidX(self.btn.frame), CGRectGetMaxY(self.btn.frame) + 5)];
}

- (void) dismissPopupView {
    [self removePopupViewController:self.popupViewController];
}

- (void)setUpPopoverViewController:(UIViewController*)viewController {
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
}

- (void)removePopupViewController:(UIViewController*)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

@end
