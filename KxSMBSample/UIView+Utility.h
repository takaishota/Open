//
//  UIView+Utility.h
//  OPNFileReader
//
//  Created by Shota Takai on 2015/05/11.
//  Copyright (c) 2015年 NRI Netcom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Utility)
/** @brief self.frame.origin.xへのショートカット */
@property (nonatomic) CGFloat x;

/** @brief self.frame.origin.yへのショートカット */
@property (nonatomic) CGFloat y;

/** @brief self.frame.size.widthへのショートカット */
@property (nonatomic) CGFloat width;

/** @brief self.frame.size.heightへのショートカット */
@property (nonatomic) CGFloat height;
@end
