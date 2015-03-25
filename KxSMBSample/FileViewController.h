//
//  FileViewController.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//

#import <UIKit/UIKit.h>

@class KxSMBItemFile;

@interface FileViewController : UIViewController <UISplitViewControllerDelegate>
@property (readwrite, nonatomic, strong) KxSMBItemFile* smbFile;
@end
