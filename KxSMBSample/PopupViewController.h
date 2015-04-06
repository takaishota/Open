//
//  PopupViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/06.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupViewController : UIViewController
- (void) showPopover : (id)sender;
- (NSString*)getSelectedServer;
@end
