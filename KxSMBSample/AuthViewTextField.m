//
//  AuthViewTextField.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/19.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import "AuthViewTextField.h"
// :: Framework ::
#import <QuartzCore/QuartzCore.h>

@implementation AuthViewTextField {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

 -(void)drawRect:(CGRect)rect {
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

- (void) setUnderLineColor:(UIColor *)underLineColor {
    _underLineColor = underLineColor;
    if (_underLineColor) {
        CGColorGetComponents([self.underLineColor CGColor]);
    }
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

@end