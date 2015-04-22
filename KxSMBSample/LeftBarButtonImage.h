//
//  LeftBarButtonImage.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/30.
//

#import <UIKit/UIKit.h>

@class LeftBarButtonImage;

@interface LeftBarButtonImage : UIImage
- (id) initWithTreeViewStatus:(BOOL)isHidden;
- (id) initWithUIImage:(NSString*)imageFileName;
@end
