//
//  AuthViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/19.
//

#import "AuthViewController.h"
// :: Other ::
#import "AuthViewTextField.h"
#import "PopupViewController.h"
#import "OPNUserEntry.h"
#import "OPNUserEntryManager.h"
#import "Server.h"

@interface AuthViewController () <UITextFieldDelegate, PopupViewDelegate>
@property (nonatomic) PopupViewController *popupViewController;
@property (nonatomic) UIButton *btn;
@end

@implementation AuthViewController {
    NSArray *_formLabels;
    NSArray *_userdefaultKeys;
    NSMutableArray *_propertyList;
    NSMutableArray *_fieldsList;
    UIColor *_backgroundColor;
    UIColor *_labelTextColor;
    UIColor *_inputTextColor;
    AuthViewTextField *_lastActiveField;
    BOOL _isUpdate;
}

#define BACKGROUND_COLOR [UIColor WhiteColor]

#pragma mark - Lifecycle
- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title =  NSLocalizedString(@"エントリを作成", nil);
        _isUpdate = NO;
    }
    return self;
}

- (id)initWithUserEntry:(OPNUserEntry*)userEntry {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"エントリを編集", nil);
        self.userEntry = userEntry;
        _isUpdate = YES;
    }
    return self;
}

- (void)loadView {
    _backgroundColor = [UIColor whiteColor];
    
    const CGFloat w = self.navigationController.view.frame.size.width;
    const CGFloat h = self.navigationController.view.frame.size.height;
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.view.backgroundColor = _backgroundColor;
    
    // プロパティの初期化
    [self initiateProperties];
    
    // テキストフィールドへの参照保持配列の初期化
    _fieldsList = [NSMutableArray array];
    
    // プロパティの参照を配列にセットする
    _propertyList = [@[@"entryName", @"targetServer", @"remoteDirectory", @"workgroup", @"userName", @"password"] mutableCopy];
    
    // フォームに表示する項目
    _formLabels      = @[@"エントリ名", @"サーバアドレス", @"リモートディレクトリ", @"ワークグループ", @"ユーザ名", @"パスワード"];
    // 対応するユーザデフォルトのキー名
    _userdefaultKeys = @[@"EntryName", @"LastServer", @"RemoteDirectory", @"Workgroup", @"Username", @"Password"];
    
    [self setupformItems];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                               action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                               target:self
                                                                               action:@selector(saveAction)];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setPopoverTextField];
    [self setFocusTextField:_fieldsList[0]];
}

int popoverNumber = 1;
- (void)setPopoverTextField {
    // サーバ入力欄をポップアップで選択するようにする
    AuthViewTextField *popoverTextField = _fieldsList[popoverNumber];
    popoverTextField.enabled = NO;
    [self setupPopupButton:(UIView*)popoverTextField];
}

- (void)setupPopupButton:(UIView*)superView {
    self.btn =[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.frame           = superView.frame;
    self.btn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.btn];
    
    [self.btn addTarget:self action:@selector(didPushShowPopupButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setFocusTextField:(AuthViewTextField*)textFiled {
    textFiled.underLineColor = self.view.tintColor;
}

#pragma mark - Private
- (OPNUserEntry*)generateEntry {
    OPNUserEntry *entry = [OPNUserEntry new];
    
    if ([self isNilOrEmpty:self.userName]) {
        NSLog(@"entryName is nill");
        return nil;
    } else {
        entry.entryName = self.entryName;
    }
    
    if ([self isNilOrEmpty:self.userName]) {
        NSLog(@"userName is nill");
        return nil;
    } else {
        entry.userName = self.userName;
    }
    
    if ([self isNilOrEmpty:self.password]) {
        NSLog(@"password is nill");
        return nil;
    } else {
        entry.password = self.password;
    }
    
    if (self.remoteDirectory) {
        entry.remoteDirectory = self.remoteDirectory;
    }
    
    if([self isNilOrEmpty:self.workgroup]) {
        entry.workgroup = self.workgroup;
    }
    
    if ([self isNilOrEmpty:self.targetServer.ip]) {
        NSLog(@"serverIp is nill");
        return nil;
    } else {
        entry.targetServer = [[Server alloc] initWithIp:self.targetServer.ip NetworkType:@"LAN"];
    }
    
    return entry;
}

- (BOOL)isNilOrEmpty :(NSString*)field{
    return (!field || [field isEqualToString:@""]);
}

- (void)initiateProperties {
    if (!self.userEntry) {
        self.entryName = [NSString string];
        self.targetServer = [[Server alloc] init];
        self.remoteDirectory  = [NSString string];
        self.workgroup = [NSString string];
        self.userName  = [NSString string];
        self.password  = [NSString string];
    } else {
        self.entryName = self.entryName;
        self.targetServer    = self.userEntry.targetServer;
        self.remoteDirectory  = self.userEntry.remoteDirectory;
        self.workgroup = self.userEntry.workgroup;
        self.userName  = self.userEntry.userName;
        self.password  = self.userEntry.password;
    }
}

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

- (void)didPushShowPopupButton {
    [self.view endEditing:YES];
    
    self.popupViewController          = [PopupViewController new];
    self.popupViewController.delegate = self;
    [self setUpPopoverViewController:self.popupViewController];
    [self.popupViewController showPopupView:CGPointMake(CGRectGetMidX(self.btn.frame), CGRectGetMaxY(self.btn.frame) + 5)];
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

- (void) setupformItems {
    for (int i = 0; i < [_formLabels count]; i++) {
        [self.view addSubview:[self generateAuthItemLabel:_formLabels[i] AtIndex:i]];
        AuthViewTextField *tf = (AuthViewTextField*)[self generateAuthTextField:_propertyList[i] AtIndex:i];
        tf.delegate           = self;
        tf.tag                = i;
        [_fieldsList addObject:tf];
        [self.view addSubview:tf];
    }
}

const CGFloat _navHeight     = 60;
const CGFloat _offsetX       = 20;
const CGFloat _labelInterval = 80;

- (UILabel*)generateAuthItemLabel:(NSString*)text AtIndex:(NSUInteger)idx{
    
    const CGFloat lWidth  = self.navigationController.view.frame.size.width - 40;
    const CGFloat lHeight = 20;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_offsetX, _labelInterval * idx + _navHeight + 70, lWidth, lHeight)];
    
    UILabel *formattedLabel = [self formatLabel:label];
    formattedLabel.text = text;
    
    return formattedLabel;
}

- (AuthViewTextField*)generateAuthTextField:(NSString*)itemValue AtIndex:(NSUInteger)itemIdx {
    
    const CGFloat tfWidth  = self.navigationController.view.frame.size.width - 40;
    const CGFloat tfHeight = 20;
    AuthViewTextField *textField = [[AuthViewTextField alloc] initWithFrame:CGRectMake(_offsetX,
                                                                                       _labelInterval * itemIdx + _navHeight + 100,
                                                                                       tfWidth,
                                                                                       tfHeight)];
    if ([[self.userEntry valueForKey:itemValue] isKindOfClass:[Server class]]) {
        Server *server = [self.userEntry valueForKey:itemValue];
        textField.text = [server valueForKey:@"ip"];
    } else {
        textField.text = [self.userEntry valueForKey:itemValue];
    }
    
    AuthViewTextField *formattedTextField = (AuthViewTextField*)[self formatTextFieldStyle:textField];
    if ([@"password" isEqualToString:itemValue]) {
        formattedTextField.secureTextEntry = YES;
    }
    
    return formattedTextField;
}

- (UILabel*)formatLabel:(UILabel*)label {
    
    label.font            = [UIFont boldSystemFontOfSize:12];
    label.backgroundColor = _backgroundColor;
    label.textColor       = _labelTextColor;
    
    return label;
}

- (UITextField*)formatTextFieldStyle:(UITextField*)textField {
    textField.backgroundColor        = _backgroundColor;
    textField.textColor              = _inputTextColor;

    return textField;
}

#pragma mark - Environment Changes
- (void) willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

#pragma mark - Button Event Handler

- (void) cancelAction
{
    // viewを閉じる
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) saveAction
{
    // テキストフィールドの情報をユーザデフォルトに保存する
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    for (int i = 0; i < [_propertyList count]; i++) {
        // テキストフィールドの参照をプロパティ、ユーザデフォルトにセットする
        UITextField *uf = _fieldsList[i];
        if ([_propertyList[i] isEqualToString:@"targetServer"]) {
            Server *server = [[Server alloc] initWithIp:uf.text NetworkType:@"LAN"];
            [self setValue:server forKey:_propertyList[i]];
        } else {
            [self setValue:uf.text forKey:_propertyList[i]];
        }
        [ud setObject:uf.text forKey:_userdefaultKeys[i]];
    }
    
    OPNUserEntry *entry = [self generateEntry];
    if (!entry) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"入力されていないフィールドがあります。" delegate:self cancelButtonTitle:@"閉じる" otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        [self commitEntry:entry forUserEntriesAtIndex:self.selectedEntryIndex];
        
        if (![ud synchronize]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"保存ができませんでした" delegate:self cancelButtonTitle:@"閉じる" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        // viewを閉じる
        [self.navigationController popViewControllerAnimated:YES];
        
        __strong id p = self.delegate;
        if (p && [p respondsToSelector:@selector(reload)])
            [p reload];
    }
}

- (void)commitEntry:(OPNUserEntry*)entry forUserEntriesAtIndex:(NSUInteger)index {
    if (_isUpdate) {
        [[OPNUserEntryManager sharedManager] updateUserEntry:entry inUserEntriesAtIndex:index];
    } else {
        [[OPNUserEntryManager sharedManager] addUserEntry:entry];
    }
}

#pragma mark - Text Field Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    AuthViewTextField *field = _fieldsList[popoverNumber];
    if (textField.tag != field.tag) {
        field.underLineColor = INFOCUS_UNDERLINE_COLOR;
    }
}

- (void)setSelectedServer:(NSString *)serverIp {
    AuthViewTextField *field = _fieldsList[popoverNumber];
    field.text = serverIp;
}

#pragma mark - Popup View Delegate
- (void)dismissPopupView {
    [self removePopupViewController:self.popupViewController];
}

#pragma mark - Alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}
#pragma mark - NSObject
- (NSString *)description
{
    return [NSString stringWithFormat:@"AuthViewController description:\n%@ delegate: %@\ntargetServer: %@\nremoteDirectory: %@\nworkgroup: %@\nuserName: %@\npassword: %@\n",[super description], self.delegate, self.targetServer, self.remoteDirectory, self.workgroup, self.userName, self.password];
}

@end
