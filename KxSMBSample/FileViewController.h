//
//  FileViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//

#import <UIKit/UIKit.h>

@class KxSMBItemFile;

@protocol FileViewControllerDelegate <NSObject>
@optional
- (void) hideTreeView:(BOOL)isHidden;
@end

@interface FileViewController : UIViewController <UISplitViewControllerDelegate>
@property (nonatomic) id <FileViewControllerDelegate> delegate;
@property (readwrite, nonatomic, strong) KxSMBItemFile* smbFile;
@end