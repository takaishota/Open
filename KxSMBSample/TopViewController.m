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
#import "PopupViewController.h"

@interface TopViewController () <UITextFieldDelegate, PopupViewDelegate>
@property (nonatomic) PopupViewController *popupViewController;
@property (nonatomic) UIButton *btn;
@property (nonatomic) UILabel *appNameLabel;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UITextField *serverTextField;
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
    
    const CGFloat labelWidth = 160;
    const CGFloat labelHeight = 100;
    const CGFloat labelX = [[UIScreen mainScreen] bounds].size.width/2- labelWidth/2;
    const CGFloat labelY = [[UIScreen mainScreen] bounds].size.height/2 - labelHeight/2 - 160;
    
    self.appNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelX,
                                                                   labelY,
                                                                   labelWidth,
                                                                   labelHeight)];
    self.appNameLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    [self setFormatTitleLabel];
    [self.view addSubview:self.appNameLabel];
    
    const CGFloat descriptionWidth = 196;
    const CGFloat descriptionHeight = 100;
    const CGFloat descriptionX = [[UIScreen mainScreen] bounds].size.width/2- descriptionWidth/2;
    const CGFloat descriptionY = [[UIScreen mainScreen] bounds].size.height/2 - descriptionWidth/2 - 70;
    
    self.descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(descriptionX,
                                                       descriptionY,
                                                       descriptionWidth,
                                                       descriptionHeight)];
    self.descriptionLabel.text = @"ファイル共有を素早く、快適に";
    [self setFormatDescriptionLabel];
    [self.view addSubview:self.descriptionLabel];
    
    UIButton *loginBtn = [self generateLoginButton];
    const CGFloat diffY = 3;
    
    [loginBtn setAlpha:0];
    [self.view addSubview:loginBtn];
    [UIView animateWithDuration:0.2
                          delay:0.4
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [loginBtn setAlpha:1.0];
                         loginBtn.frame = CGRectMake(loginBtn.frame.origin.x,
                                                     loginBtn.frame.origin.y - diffY,
                                                     loginBtn.frame.size.width,
                                                     loginBtn.frame.size.height);
                     }completion:nil];
    
    
    [MLPSpotlight addSpotlightInView:self.view atPoint:self.appNameLabel.center];
            
}

#pragma mark - Private

- (UIButton*)generateLoginButton {
    const CGFloat W = 190;
    const CGFloat H = 44;
    const CGFloat X = [[UIScreen mainScreen] bounds].size.width/2 - W/2;
    const CGFloat Y = [[UIScreen mainScreen] bounds].size.height/2 - H/2;
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginBtn.frame = CGRectMake(X, Y+H, W, H);
    loginBtn.backgroundColor = [UIColor whiteColor];
    [loginBtn.layer setCornerRadius:4.0];
    loginBtn.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16];
    [loginBtn setTitle:@"接続" forState:UIControlStateNormal];
    [loginBtn setTitleColor:TOP_BACKGROUND_COLOR forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(showLoginViewController) forControlEvents:UIControlEventTouchUpInside];
    
    return loginBtn;
}

- (void)setFormatTitleLabel {
    self.appNameLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:60];
    self.appNameLabel.backgroundColor = [UIColor clearColor];
    self.appNameLabel.textColor       = [UIColor whiteColor];
}

- (void)setFormatDescriptionLabel {
    self.descriptionLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    self.descriptionLabel.textColor       = [UIColor whiteColor];
}

- (void)showLoginViewController {
    
    // 認証ダイアログを表示する
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS 8の時の処理
        UIAlertController *alertController = [self generateAlertController];
        alertController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:alertController animated:YES completion:nil];
    }else {
        // iOS 7以前の処理
        UIAlertView *alert = [self generateAlertView];
        [alert show];
    }
}

- (UIAlertController *)generateAlertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ログイン"
                                                                             message:@"ログイン情報を入力してください"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        self.serverTextField = textField;
        [self formatTextField:textField];
        textField.placeholder = @"サーバアドレス";
        textField.delegate    = self;
    }];
    
    // TODO:設定画面でON/OFFできるようにする
    BOOL isAvailableLastLoginSetting = NO;
    if (!isAvailableLastLoginSetting) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"ユーザネーム";
            [self formatTextField:textField];
            textField.delegate    = self;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"パスワード";
            textField.secureTextEntry = true;
            [self formatTextField:textField];
        }];
    }
    
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect = self.view.bounds;
    alertController.popoverPresentationController.permittedArrowDirections = 0;
    [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // キャンセルボタンが押された時の処理
        [self cancelButtonDidPushed];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"ログイン" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // ログインボタンが押された時の処理
        [self loginButtonDidPushed];
    }]];
    return alertController;
}

- (UIAlertView *)generateAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ログイン"
                               message:@"ログイン情報を入力してください"
                              delegate:self
                     cancelButtonTitle:@"キャンセル"
                     otherButtonTitles:@"ログイン", nil];
    
    // TODO:iOS7以下の処理
    
    return alertView;
}
- (void)formatTextField:(UITextField *)textField {
    
}

- (void)loginButtonDidPushed {
    [LoginStatusManager sharedManager].isLogin = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)cancelButtonDidPushed {}


@end
