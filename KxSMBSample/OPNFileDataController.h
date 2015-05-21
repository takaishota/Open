//
//  OPNFileDataController.h
//  OPNFileReader
//
//  Created by Shota Takai on 2015/05/22.
//  Copyright (c) 2015年 NRI Netcom. All rights reserved.
//  FileViewControllerクラスの状態を管理するクラス
//
//

#import <Foundation/Foundation.h>

@interface OPNFileDataController : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isLandscape;
- (BOOL)isPortrait;

@property (nonatomic) BOOL treeViewIsHidden;
@property (nonatomic) BOOL isNavigationBarHidden;
@property (nonatomic) BOOL currentFileIsPdf;
@end
