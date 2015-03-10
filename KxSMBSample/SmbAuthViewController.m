//
//  SmbAuthViewController.m
//  kxsmb project
//  https://github.com/kolyvan/kxsmb/
//
//  Created by Kolyvan on 29.03.13.
//

/*
 Copyright (c) 2013 Konstantin Bukreev All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import "SmbAuthViewController.h"

@interface SmbAuthViewController ()
@end

@implementation SmbAuthViewController {

    UILabel     *_pathLabel;
    UITextField *_workgroupField;
    UITextField *_usernameField;
    UITextField *_passwordField;
}

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title =  NSLocalizedString(@"SMB Authorization", nil);
    }
    return self;
}

- (void) loadView
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];    
    const CGFloat W = frame.size.width;
    const CGFloat H = frame.size.height;
    UIFont *const fontSize = [UIFont boldSystemFontOfSize:16];
    
    const int labelPositionX = 10;
    const int labelFirstPositionY = 64;
    const int labelWidth = 90;
    const int labelHeight = 30;
    UIColor *const labelBackgroundColor = [UIColor clearColor];
    UIColor *const labelTextColor = [UIColor darkTextColor];
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, H)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _pathLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelPositionX, labelFirstPositionY + 20, W-20,labelHeight)];
    _pathLabel.backgroundColor = labelBackgroundColor;
    _pathLabel.textColor = labelTextColor;
    _pathLabel.font = fontSize;
    [self.view addSubview:_pathLabel];
    
    UILabel *workgroupLabel;
    workgroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelPositionX,labelFirstPositionY + 70,labelWidth,labelHeight)];
    workgroupLabel.backgroundColor = labelBackgroundColor;
    workgroupLabel.textColor = labelTextColor;
    workgroupLabel.font = fontSize;
    workgroupLabel.text = NSLocalizedString(@"Workgroup", nil);
    [self.view addSubview:workgroupLabel];
    
    UILabel *usernameLabel;
    usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelPositionX,labelFirstPositionY + 120,labelWidth,labelHeight)];
    usernameLabel.backgroundColor = labelBackgroundColor;
    usernameLabel.textColor = labelTextColor;
    usernameLabel.font = fontSize;
    usernameLabel.text = NSLocalizedString(@"Username", nil);
    [self.view addSubview:usernameLabel];
    
    UILabel *passwordLabel;
    passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelPositionX,labelFirstPositionY + 170,labelWidth,labelHeight)];
    passwordLabel.backgroundColor = labelBackgroundColor;
    passwordLabel.textColor = labelTextColor;
    passwordLabel.font = fontSize;
    passwordLabel.text = NSLocalizedString(@"Password", nil);    
    [self.view addSubview:passwordLabel];
    
    const int textFieldPositionX = 100;
    const int textFieldFirstPositionY = 41;
    UIColor *const textFieldBackgroundColor = [UIColor whiteColor];
    UIColor *const textFieldTextColor = [UIColor darkGrayColor];
    
    _workgroupField = [[UITextField alloc] initWithFrame:CGRectMake(textFieldPositionX, textFieldFirstPositionY + 100, W - 110, labelHeight)];
    _workgroupField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _workgroupField.autocorrectionType = UITextAutocorrectionTypeNo;
    _workgroupField.spellCheckingType = UITextSpellCheckingTypeNo;
    _workgroupField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _workgroupField.clearButtonMode =  UITextFieldViewModeWhileEditing;
    _workgroupField.textColor = textFieldTextColor;
    _workgroupField.font = fontSize;
    _workgroupField.borderStyle = UITextBorderStyleRoundedRect;
    _workgroupField.backgroundColor = textFieldBackgroundColor;
    _workgroupField.returnKeyType = UIReturnKeyNext;
    
    [_workgroupField addTarget:self
                    action:@selector(textFieldDoneEditing:)
          forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.view addSubview:_workgroupField];
    
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(textFieldPositionX, textFieldFirstPositionY + 150, W - 110, labelHeight)];
    _usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    _usernameField.spellCheckingType = UITextSpellCheckingTypeNo;
    _usernameField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _usernameField.clearButtonMode =  UITextFieldViewModeWhileEditing;
    _usernameField.textColor = textFieldTextColor;
    _usernameField.font = fontSize;
    _usernameField.borderStyle = UITextBorderStyleRoundedRect;
    _usernameField.backgroundColor = textFieldBackgroundColor;
    _usernameField.returnKeyType = UIReturnKeyDone;
    
    [_usernameField addTarget:self
                   action:@selector(textFieldDoneEditing:)
         forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.view addSubview:_usernameField];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(textFieldPositionX, textFieldFirstPositionY + 200, W - 110, labelHeight)];
    _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordField.spellCheckingType = UITextSpellCheckingTypeNo;
    _passwordField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _passwordField.clearButtonMode =  UITextFieldViewModeWhileEditing;
    _passwordField.textColor = textFieldTextColor;
    _passwordField.font = fontSize;
    _passwordField.borderStyle = UITextBorderStyleRoundedRect;
    _passwordField.backgroundColor = textFieldBackgroundColor;
    _passwordField.returnKeyType = UIReturnKeyDone;
    _passwordField.secureTextEntry = YES;    
    
    [_passwordField addTarget:self
                       action:@selector(textFieldDoneEditing:)
             forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.view addSubview:_passwordField];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *bbi;
    
    bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                        target:self
                                                        action:@selector(doneAction)];
    
    self.navigationItem.rightBarButtonItem = bbi;
    
    bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                        target:self
                                                        action:@selector(cancelAction)];
    
    self.navigationItem.leftBarButtonItem = bbi;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _pathLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Server: %@", nil), _server];
    _workgroupField.text = _workgroup;
    _usernameField.text = _username;
    _passwordField.text = _password;
    
    [_workgroupField becomeFirstResponder];
}

- (void) textFieldDoneEditing: (id) sender
{
}

- (void) cancelAction
{
    __strong id p = self.delegate;
    if (p && [p respondsToSelector:@selector(couldSmbAuthViewController:done:)])
        [p couldSmbAuthViewController:self done:NO];
}

- (void) doneAction
{
    _workgroup = _workgroupField.text;
    _username = _usernameField.text;
    _password = _passwordField.text;
    
    __strong id p = self.delegate;
    if (p && [p respondsToSelector:@selector(couldSmbAuthViewController:done:)])
        [p couldSmbAuthViewController:self done:YES];
}

@end
