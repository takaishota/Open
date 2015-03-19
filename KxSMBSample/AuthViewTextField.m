//
//  AuthViewTextField.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/19.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import "AuthViewTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation AuthViewTextField {
    CALayer *underCALayer;
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
     
     CGContextSetRGBStrokeColor(ctx, 0.933, 0.933, 0.933, 1.0);
     CGContextMoveToPoint(ctx, 0, self.frame.size.height);
     CGContextSetLineWidth(ctx, 2.0);
     CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height);
     CGContextStrokePath(ctx);
 }

@end