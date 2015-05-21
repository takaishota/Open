//
//  OPNFileDataController.m
//  OPNFileReader
//
//  Created by Shota Takai on 2015/05/22.
//  Copyright (c) 2015年 NRI Netcom. All rights reserved.
//

#import "OPNFileDataController.h"

@implementation OPNFileDataController

#pragma mark - LifeCycle
+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isNavigationBarHidden = NO;
        
        // ディレクトリの表示状態保持変数の初期化
        if ([self isLandscape]) {
            self.treeViewIsHidden = NO;
        } else {
            self.treeViewIsHidden = YES;
        }
    }
    return self;
}

#pragma mark - Public
- (BOOL)isLandscape {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (BOOL)isPortrait {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
