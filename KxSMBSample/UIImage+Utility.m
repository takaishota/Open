//
//  UIImage+Utility.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/22.
//

#import "UIImage+Utility.h"

enum {
    ImageRightArrow,
    ImageLeftArrow,
};

@implementation UIImage(Utility)

#pragma mark - Lifecycle
//- (id) initWithTreeViewStatus:(BOOL)isHidden deviceOrientation:(BOOL)orientationIsLandScape {
//    
//    self = [super init];
//    // 自分のステータスを見てセットする画像を変更する
//    if (self) {
//        NSString *image = nil;
//        
//        switch ([self getImageTypeWithHidden:isHidden deviceOrientation:orientationIsLandScape]) {
//            case ImageLeftArrow:
//                image = @"left.png";
//                break;
//            case ImageRightArrow:
//                image = @"right.png";
//                break;
//            default:
//                return self;
//                break;
//        }
//        
//        self = [self resizeImage:image];
//    }
//    return self;
//}

- (id) initWithUIImage:(NSString *)imageFileName {
    self = [super init];
    if (self) {
        self = [self resizeImage:imageFileName];
    }
    
    return self;
}

#pragma mark - Private
- (NSUInteger)getImageTypeWithHidden:(BOOL)popupGetHidden
                   deviceOrientation:(BOOL)toOrientationIsPortrait {
    NSUInteger imgType = 0;
    if (toOrientationIsPortrait) {
        imgType = ImageRightArrow;
    } else {
        if (popupGetHidden) {
            imgType = ImageRightArrow;
        } else {
            imgType = ImageLeftArrow;
        }
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
