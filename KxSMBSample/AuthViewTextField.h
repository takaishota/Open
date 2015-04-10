//
//  AuthViewTextField.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/19.
//

#import <UIKit/UIKit.h>

@interface AuthViewTextField : UITextField
@property (nonatomic) UIColor *underLineColor;
@property (nonatomic) CGFloat lineWidth;
- (void)setTextFieldStyle;
@end