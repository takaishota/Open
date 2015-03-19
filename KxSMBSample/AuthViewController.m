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
}

- (void)loadView {
    const CGFloat w = self.navigationController.view.frame.size.width;
    const CGFloat h = self.navigationController.view.frame.size.height;
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"SMB認証情報の設定";
    
    const CGFloat navHeight = 60;
    const CGFloat offsetX = 20;
    const CGFloat lWidth = w - 40;
    const CGFloat lHeight = 20;
    const CGFloat tfWidth = w - 40;
    const CGFloat tfHeight = 40;
    
    UILabel *pathLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, navHeight + 70, lWidth, lHeight)];
    [self formatLabel:pathLabel];
    pathLabel.text = @"サーバアドレス";
    [self.view addSubview:pathLabel];
    
    _pathField = [[AuthViewTextField alloc] initWithFrame:CGRectMake(offsetX, navHeight + 100, tfWidth, tfHeight)];
    [self formatTextFieldStyle:_pathField];
    [self.view addSubview:_pathField];
    
    UILabel *workgroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, navHeight +  150, lWidth, lHeight)];
    [self formatLabel:workgroupLabel];
    workgroupLabel.text = @"ワークグループ";
    [self.view addSubview:workgroupLabel];
    
    _workgroupField = [[AuthViewTextField alloc] initWithFrame:CGRectMake(offsetX, navHeight + 180, tfWidth, tfHeight)];
    [self formatTextFieldStyle:_workgroupField];
    [self.view addSubview:_workgroupField];
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, navHeight + 230, lWidth, lHeight)];
    [self formatLabel:userNameLabel];
    userNameLabel.text = @"ユーザ名";
    [self.view addSubview:userNameLabel];
    
    _usernameField = [[AuthViewTextField alloc] initWithFrame:CGRectMake(offsetX, navHeight + 260, tfWidth, tfHeight)];
    [self formatTextFieldStyle:_usernameField];
    [self.view addSubview:_usernameField];
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, navHeight + 310, lWidth, lHeight)];
    [self formatLabel:passwordLabel];
    passwordLabel.text = @"パスワード";
    [self.view addSubview:passwordLabel];
    
    _passwordField = [[AuthViewTextField alloc] initWithFrame:CGRectMake(offsetX, navHeight + 340, tfWidth, tfHeight)];
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
    [_pathField becomeFirstResponder];
}

- (UILabel*)formatLabel:(UILabel*)label {
    
    label.font = [UIFont boldSystemFontOfSize:12];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor grayColor];
    
    return label;
}

- (UITextField*)formatTextFieldStyle:(UITextField*)textField {
    
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.clearButtonMode =  UITextFieldViewModeWhileEditing;
    textField.textColor = [UIColor darkGrayColor];
    textField.font = [UIFont boldSystemFontOfSize:16];
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = [UIColor whiteColor];
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
