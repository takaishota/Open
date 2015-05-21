//
//  OPNFileViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//

#import <UIKit/UIKit.h>

@class KxSMBItemFile;

@protocol OPNFileViewControllerDelegate <NSObject>
@optional
- (void)hideTreeView;
- (void)showTreeView;
@end

@interface OPNFileViewController : UIViewController <UISplitViewControllerDelegate>
@property (nonatomic) id <OPNFileViewControllerDelegate> delegate;
@property (readwrite, nonatomic, strong) KxSMBItemFile* smbFile;
@end