//
//  AuthViewController.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/19.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import "AuthViewController.h"

@interface AuthViewController ()

@end

@implementation AuthViewController {
    UITextField *_pathField;
    UITextField *_workgroupField;
    UITextField *_usernameField;
    UITextField *_passwordField;
}

- (void)loadView {
    const CGFloat w = self.navigationController.view.frame.size.width;
    const CGFloat h = self.navigationController.view.frame.size.height;
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
//    self.view.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"SMB認証情報の設定";
    
    const CGFloat navHeight = 60;
    const CGFloat offsetX = 20;
    const CGFloat tfWidth = w - 40;
    const CGFloat tfHeight = 40;
    
    _pathField = [[UITextField alloc] initWithFrame:CGRectMake(offsetX, navHeight + 100, tfWidth, tfHeight)];
    [self formatTextFieldStyle:_pathField];
    [self.view addSubview:_pathField];
    
    _workgroupField = [[UITextField alloc] initWithFrame:CGRectMake(offsetX, navHeight + 180, tfWidth, tfHeight)];
    [self formatTextFieldStyle:_workgroupField];
    [self.view addSubview:_workgroupField];
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(offsetX, navHeight + 260, tfWidth, tfHeight)];
    [self formatTextFieldStyle:_usernameField];
    [self.view addSubview:_usernameField];
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(offsetX, navHeight + 340, tfWidth, tfHeight)];
    [self formatTextFieldStyle:_passwordField];
    _passwordField.secureTextEntry = YES;
    [self.view addSubview:_passwordField];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_workgroupField becomeFirstResponder];
}

- (UITextField*)formatTextFieldStyle:(UITextField*)textField {
    
    UIFont *const fontSize = [UIFont boldSystemFontOfSize:16];
    UIColor *const textFieldBackgroundColor = [UIColor whiteColor];
    UIColor *const textFieldTextColor = [UIColor darkGrayColor];
    
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.clearButtonMode =  UITextFieldViewModeWhileEditing;
    textField.textColor = textFieldTextColor;
    textField.font = fontSize;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = textFieldBackgroundColor;
    textField.returnKeyType = UIReturnKeyNext;
    
    return textField;
}


- (void) textFieldDoneEditing: (id) sender
{
}

- (void) cancelAction
{
    // viewを閉じる
}

- (void) doneAction
{
    // テキストフィールドの情報を保存して、共有サーバに接続する
    // viewを閉じる

}

@end
