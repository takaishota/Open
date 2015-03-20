//
//  AuthViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/19.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import "AuthViewController.h"
#import "AuthViewTextField.h"

@interface AuthViewController ()

@end

@implementation AuthViewController {
    UITextField *_pathField;
    UITextField *_workgroupField;
    UITextField *_usernameField;
    UITextField *_passwordField;
    UIColor *_backgroundColor;
    UIColor *_labelTextColor;
    UIColor *_inputTextColor;
}

#define BACKGROUND_COLOR [UIColor WhiteColor]

- (void)loadView {
    _backgroundColor = [UIColor whiteColor];
    
    const CGFloat w = self.navigationController.view.frame.size.width;
    const CGFloat h = self.navigationController.view.frame.size.height;
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.view.backgroundColor = _backgroundColor;
    
    self.title = @"SMB認証情報の設定";
    
    [self.view addSubview:[self generateAuthItemLabel:@"サーバアドレス" AtIndex:0]];
    _pathField = [self generateAuthTextField:@"172.18.34.230" AtIndex:0 IsPasswordFormat:NO];
    [self.view addSubview:_pathField];
    
    [self.view addSubview:[self generateAuthItemLabel:@"ワークグループ" AtIndex:1]];
    _workgroupField = [self generateAuthTextField:@"WORKGROUP" AtIndex:1 IsPasswordFormat:NO];
    [self.view addSubview:_workgroupField];
    
    [self.view addSubview:[self generateAuthItemLabel:@"ユーザ名" AtIndex:2]];
    _usernameField = [self generateAuthTextField:@"s-takai" AtIndex:2 IsPasswordFormat:NO];
    [self.view addSubview:_usernameField];
    
    [self.view addSubview:[self generateAuthItemLabel:@"パスワード" AtIndex:3]];
    _passwordField = [self generateAuthTextField:@"e9GNHwWh" AtIndex:3 IsPasswordFormat:YES];
    [self.view addSubview:_passwordField];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneAction)];
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

const CGFloat _navHeight = 60;
const CGFloat _offsetX = 20;
const CGFloat _labelInterval = 80;

- (UILabel*)generateAuthItemLabel:(NSString*)text AtIndex:(NSUInteger)idx{
    
    const CGFloat lWidth = self.navigationController.view.frame.size.width - 40;
    const CGFloat lHeight = 20;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_offsetX, _labelInterval * idx + _navHeight + 70, lWidth, lHeight)];
    UILabel *formattedLabel = [self formatLabel:label];
    formattedLabel.text = text;
    return formattedLabel;
}

- (UITextField*)generateAuthTextField:(NSString*)lastValue AtIndex:(NSUInteger)idx IsPasswordFormat:(BOOL)isPass{
    
    const CGFloat tfWidth = self.navigationController.view.frame.size.width - 40;
    const CGFloat tfHeight = 20;
    
    UITextField *textField = [[AuthViewTextField alloc] initWithFrame:CGRectMake(_offsetX, _labelInterval * idx + _navHeight + 100, tfWidth, tfHeight)];
    UITextField *formattedTextField = [self formatTextFieldStyle:textField];
    formattedTextField.text = lastValue;
    formattedTextField.secureTextEntry = isPass;
    return formattedTextField;
}

- (UILabel*)formatLabel:(UILabel*)label {
    
    label.font = [UIFont boldSystemFontOfSize:12];
    label.backgroundColor = _backgroundColor;
    label.textColor = _labelTextColor;
    
    return label;
}

- (UITextField*)formatTextFieldStyle:(UITextField*)textField {
    
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.clearButtonMode =  UITextFieldViewModeWhileEditing;
    textField.textColor = _inputTextColor;
    textField.font = [UIFont systemFontOfSize:16];
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = _backgroundColor;
    textField.returnKeyType = UIReturnKeyNext;
    
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

- (void) doneAction
{
    // テキストフィールドの情報をユーザデフォルトに保存する
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *pathStringAddedProtocol = [NSString stringWithFormat:@"smb:%@", _pathField.text];
    
    [ud setObject:pathStringAddedProtocol forKey:@"Path"];
    [ud setObject:_workgroupField.text forKey:@"Workgroup"];
    [ud setObject:_usernameField.text forKey:@"Username"];
    [ud setObject:_passwordField.text forKey:@"Password"];
    BOOL doneSynchronized = [ud synchronize];
    
    if (!doneSynchronized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"保存ができませんでした" delegate:self cancelButtonTitle:@"閉じる" otherButtonTitles:nil, nil];
        [alert show];
    }
    // viewを閉じる
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - Alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

@end
