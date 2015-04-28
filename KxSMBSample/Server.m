//
//  Server.m
//  SMBFileReader
//
//  Created by ShotaTakai on 2015/04/05.
//

#import "Server.h"

@implementation Server

#pragma mark - Lifecycle
- (id) initWithIp:(NSString*)ip NetworkType:(NSString*)type {
    self = [super init];
    if (self) {
        _ip = ip;
        _networkType = type;
    }
    return self;
}
#pragma mark - NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:_ip forKey:@"_ip"];
    [coder encodeObject:_networkType forKey:@"_networkType"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self){
        _ip = [decoder decodeObjectForKey:@"_ip"];
        _networkType = [decoder decodeObjectForKey:@"_networkType"];
    }
    return self;
}


#pragma mark - NSObject
- (NSString *)description
{
    return [NSString stringWithFormat:@"Server description:\n%@ ip: %@\nnetworkType: %@\n",[super description], self.ip, self.networkType];
}

@end
