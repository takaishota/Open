//
//  LeftBarButtonImage.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/30.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import "LeftBarButtonImage.h"

@interface LeftBarButtonImage () {
    BOOL _popupIsHidden;
}
@end

enum {
    ImageRightArrow,
    ImageLeftArrow,
};

@implementation LeftBarButtonImage
- (id) initWithTreeViewStatus:(BOOL)isHidden{

    self = [super init];
    // 自分のステータスを見てセットする画像を変更する
    if (self) {
        NSString *image = nil;
        _popupIsHidden = isHidden;
        
        switch ([self getImageType]) {
            case ImageLeftArrow:
                image = @"left.png";
                break;
            case ImageRightArrow:
                image = @"right.png";
                break;
            default:
                return self;
                break;
        }
        
        self = (LeftBarButtonImage*)[self resizeImage:image];
    }
    return self;
}

- (NSUInteger)getImageType {
    NSUInteger imgType = 0;
    if (_popupIsHidden) {
        imgType = ImageRightArrow;
    } else {
        imgType = ImageLeftArrow;
    }
    return imgType;
}

- (UIImage*)resizeImage:(NSString*)fileName {
    UIImage *img   = [UIImage imageNamed:fileName];
    CGFloat width  = 28;
    CGFloat height = 28;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [img drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *resizeImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizeImg;
}

@end
