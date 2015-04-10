//
//  TopViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/09.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TopViewController;

@protocol TopViewControllerDelegate <NSObject>
@optional
- (void) dismissTopViewController;
@end

@interface TopViewController : UIViewController
@property (nonatomic) id <TopViewControllerDelegate> delegate;
@end
