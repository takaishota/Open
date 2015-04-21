//
//  Server.m
//  SMBFileReader
//
//  Created by ShotaTakai on 2015/04/05.
//

#import "Server.h"

@implementation Server

- (id) initWithIp:(NSString*)ip NetworkType:(NSString*)type {
    self = [super init];
    if (self) {
        _ip = ip;
        _networkType = type;
    }
    return self;
}

#pragma mark - NSObject
- (NSString *)description
{
    return [NSString stringWithFormat:@"Server description:\n%@ ip: %@\nnetworkType: %@\n",[super description], self.ip, self.networkType];
}

@end
