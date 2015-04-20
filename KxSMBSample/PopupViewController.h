//
//  PopupViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/06.
//

#import <UIKit/UIKit.h>
@class PopupViewController;

@protocol PopupViewDelegate <NSObject>
@optional
- (void)dismissPopupView;
- (void)setSelectedServer:(NSString*)serverIp;
@end

@interface PopupViewController : UIViewController
@property (nonatomic, weak) id <PopupViewDelegate>delegate;
- (void) showPopupView : (CGPoint)point;
- (NSString*)getSelectedServer;
@end
