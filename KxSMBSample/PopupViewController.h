//
//  PopupViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/06.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PopupViewController;

@protocol PopupViewDelegate <NSObject>
@optional
- (void) dismissPopupView;
@end

@interface PopupViewController : UIViewController
@property (nonatomic, weak) id <PopupViewDelegate>delegate;
- (void) showPopupView : (CGPoint)point;
- (NSString*)getSelectedServer;
@end
