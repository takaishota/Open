//
//  AuthViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/19.
//

#import "AuthViewController.h"
#import "AuthViewTextField.h"

@implementation AuthViewController {
    UITextField *_pathField;
    UITextField *_workgroupField;
    UITextField *_usernameField;
    UITextField *_passwordField;
    NSArray *_formLabels;
    NSArray *_userdefaultKeys;
    NSMutableArray *_propertyList;
    NSMutableArray *_fieldsList;
    UIColor *_backgroundColor;
    UIColor *_labelTextColor;
    UIColor *_inputTextColor;
}


- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title =  NSLocalizedString(@"SMB認証情報の設定", nil);
    }
    return self;
}

#define BACKGROUND_COLOR [UIColor WhiteColor]

- (void)loadView {
    _backgroundColor = [UIColor whiteColor];
    
    const CGFloat w = self.navigationController.view.frame.size.width;
    const CGFloat h = self.navigationController.view.frame.size.height;
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.view.backgroundColor = _backgroundColor;
    
    // プロパティの初期化
    _server    = [NSString string];
    _localDir  = [NSString string];
    _workgroup = [NSString string];
    _username  = [NSString string];
    _password  = [NSString string];
    
    // テキストフィールドへの参照保持配列の初期化
    _fieldsList = [NSMutableArray array];
    
    // プロパティの参照を配列にセットする
    _propertyList = [@[_server, _workgroup, _localDir, _username, _password] mutableCopy];
    
    // フォームに表示する項目
    _formLabels      = @[@"サーバアドレス", @"リモートディレクトリ", @"ワークグループ", @"ユーザ名", @"パスワード"];
    _userdefaultKeys = @[@"LastServer", @"RemoteDirectory", @"Workgroup", @"Username", @"Password"];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_pathField becomeFirstResponder];
}

- (void) setupformItems {
    for (int i = 0; i < [_formLabels count]; i++) {
        [self.view addSubview:[self generateAuthItemLabel:_formLabels[i] AtIndex:i]];
        UITextField *tf = [self generateAuthTextField:_userdefaultKeys[i] AtIndex:i];
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

- (UITextField*)generateAuthTextField:(NSString*)lastValue AtIndex:(NSUInteger)idx {
    
    const CGFloat tfWidth  = self.navigationController.view.frame.size.width - 40;
    const CGFloat tfHeight = 20;
    
    UITextField *textField = [[AuthViewTextField alloc] initWithFrame:CGRectMake(_offsetX, _labelInterval * idx + _navHeight + 100, tfWidth, tfHeight)];
    UITextField *formattedTextField = [self formatTextFieldStyle:textField];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    formattedTextField.text = [ud stringForKey:lastValue];
    if ([@"Password" isEqualToString:lastValue]) {
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
    
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType     = UITextAutocorrectionTypeNo;
    textField.spellCheckingType      = UITextSpellCheckingTypeNo;
    textField.autoresizingMask       = UIViewAutoresizingFlexibleWidth;
    textField.clearButtonMode        = UITextFieldViewModeWhileEditing;
    textField.textColor              = _inputTextColor;
    textField.font                   = [UIFont systemFontOfSize:16];
    textField.borderStyle            = UITextBorderStyleNone;
    textField.backgroundColor        = _backgroundColor;
    textField.returnKeyType          = UIReturnKeyNext;

    return textField;
}


- (void) textFieldDoneEditing: (id) sender
{
}

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
        _propertyList[i] = uf.text;
        [ud setObject:uf.text forKey:_userdefaultKeys[i]];
    }
    BOOL doneSynchronized = [ud synchronize];
    
    if (!doneSynchronized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"保存ができませんでした" delegate:self cancelButtonTitle:@"閉じる" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    // viewを閉じる
    [self.navigationController popViewControllerAnimated:YES];
    
    __strong id p = self.delegate;
    if (p && [p respondsToSelector:@selector(couldAuthViewController:done:)])
        [p couldAuthViewController:self done:YES];
    
}

#pragma mark - Alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

@end
