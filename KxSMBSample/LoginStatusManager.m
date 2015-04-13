//
//  LoginStatusManager.m
//  SMBFileReader
//
//  Created by ShotaTakai on 2015/04/12.
//

#import "LoginStatusManager.h"
#import "Server.h"

@implementation LoginStatusManager
+ (LoginStatusManager*)sharedManager
{
    static LoginStatusManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[LoginStatusManager alloc] initSharedManager];
    });
    return sharedManager;
}

- (id)initSharedManager
{
    self = [super init];
    if (self) {
        _isLogin = NO;
    }
    return self;
}

@end