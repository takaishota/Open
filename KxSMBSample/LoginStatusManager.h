//
//  LoginStatusManager.h
//  SMBFileReader
//
//  Created by ShotaTakai on 2015/04/12.
//

#import <Foundation/Foundation.h>
@class Server;

@interface LoginStatusManager : NSObject
@property (nonatomic) BOOL isLogin;
@property (nonatomic) BOOL isLaunchedApp;
+ (LoginStatusManager*)sharedManager;
@end
