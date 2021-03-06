//
//  AuthViewTextField.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/19.
//

#import "AuthViewTextField.h"
// :: Framework ::
#import <QuartzCore/QuartzCore.h>

@implementation AuthViewTextField {
}

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setTextFieldStyle];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx, NO);
    
    const CGFloat *colorComponents;
    if (self.underLineColor) {
        colorComponents = CGColorGetComponents([self.underLineColor CGColor]);
    } else {
        colorComponents = CGColorGetComponents([INFOCUS_UNDERLINE_COLOR CGColor]);
    }
    CGContextSetRGBStrokeColor(ctx, colorComponents[0], colorComponents[1], colorComponents[2], 1.0);
    CGContextMoveToPoint(ctx, 0, self.frame.size.height);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height);
    CGContextStrokePath(ctx);
}

#pragma mark - Private
- (void)setTextFieldStyle {
   self.autocapitalizationType = UITextAutocapitalizationTypeNone;
   self.autocorrectionType     = UITextAutocorrectionTypeNo;
   self.spellCheckingType      = UITextSpellCheckingTypeNo;
   self.autoresizingMask       = UIViewAutoresizingFlexibleWidth;
   self.clearButtonMode        = UITextFieldViewModeWhileEditing;
   self.font                   = [UIFont systemFontOfSize:16];
   self.borderStyle            = UITextBorderStyleNone;
   self.returnKeyType          = UIReturnKeyNext;
}

- (void) setUnderLineColor:(UIColor *)underLineColor {
    _underLineColor = underLineColor;
    [self setNeedsDisplay];
    if (_underLineColor) {
        CGColorGetComponents([self.underLineColor CGColor]);
    }
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (BOOL)becomeFirstResponder {
    self.underLineColor = self.tintColor;
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    self.underLineColor = INFOCUS_UNDERLINE_COLOR;
    return [super resignFirstResponder];
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"AuthViewTextField description:\n%@ underLineColor: %@\nlineWidth: %f\n",[super description], self.underLineColor, self.lineWidth];
}

@end