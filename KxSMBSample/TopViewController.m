//
//  TopViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/09.
//

#import "TopViewController.h"
#import "AuthViewTextField.h"
#import "LoginStatusManager.h"
#import "MLPSpotlight.h"

@interface TopViewController () <UITextFieldDelegate>
@property (nonatomic) UILabel *appNameLabel;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UIButton *loginButton;
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
    
    self.appNameLabel = [UILabel new];
    self.appNameLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    [self setFormatAppNameLabel:self.appNameLabel];
    [self.view addSubview:self.appNameLabel];
    
    self.descriptionLabel = [UILabel new];
    self.descriptionLabel.text = @"ファイル共有を素早く、快適に";
    [self setFormatDescriptionLabel:self.descriptionLabel];
    [self.view addSubview:self.descriptionLabel];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.loginButton = loginButton;
    [self setFormatLoginBtn:loginButton];
    
    const CGFloat diffY = 3;
    
    [loginButton setAlpha:0];
    [self.view addSubview:loginButton];
    [UIView animateWithDuration:0.2
                          delay:0.4
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [loginButton setAlpha:1.0];
                         loginButton.frame = CGRectMake(loginButton.frame.origin.x,
                                                     loginButton.frame.origin.y - diffY,
                                                     loginButton.frame.size.width,
                                                     loginButton.frame.size.height);
                     }completion:nil];
    
    [MLPSpotlight addSpotlightInView:self.view atPoint:self.appNameLabel.center];
            
}

#pragma mark - When Rotate
- (void)viewDidLayoutSubviews {
    [self setFormatAppNameLabel:self.appNameLabel];
    [self setFormatDescriptionLabel:self.descriptionLabel];
    [self setFormatLoginBtn:self.loginButton];
}

#pragma mark - Private
- (UIButton*)setFormatLoginBtn:(UIButton*)button {
    const CGFloat W = 190;
    const CGFloat H = 44;
    const CGFloat X = [[UIScreen mainScreen] bounds].size.width/2 - W/2;
    const CGFloat Y = [[UIScreen mainScreen] bounds].size.height/2 - H/2;
    
    button.frame = CGRectMake(X, Y+H, W, H);
    button.backgroundColor = [UIColor whiteColor];
    [button.layer setCornerRadius:4.0];
    button.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16];
    [button setTitle:@"接続" forState:UIControlStateNormal];
    [button setTitleColor:TOP_BACKGROUND_COLOR forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openAppButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)setFormatAppNameLabel:(UILabel*)label {
    const CGFloat labelWidth = 160;
    const CGFloat labelHeight = 100;
    const CGFloat labelX = [[UIScreen mainScreen] bounds].size.width/2- labelWidth/2;
    const CGFloat labelY = [[UIScreen mainScreen] bounds].size.height/2 - labelHeight/2 - 160;
    
    label.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    self.appNameLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:60];
    self.appNameLabel.backgroundColor = [UIColor clearColor];
    self.appNameLabel.textColor       = [UIColor whiteColor];
}

- (void)setFormatDescriptionLabel:(UILabel*)label {
    const CGFloat labelWidth = 196;
    const CGFloat labelHeight = 100;
    const CGFloat labelX = [[UIScreen mainScreen] bounds].size.width/2- labelWidth/2;
    const CGFloat labelY = [[UIScreen mainScreen] bounds].size.height/2 - labelWidth/2 - 70;
    
    label.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    self.descriptionLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    self.descriptionLabel.textColor       = [UIColor whiteColor];
}

- (void)openAppButtonDidPushed {
    [LoginStatusManager sharedManager].isLaunchedApp = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
