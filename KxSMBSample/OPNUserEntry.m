//
//  OPNUserEntry.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/21.
//

#import "OPNUserEntry.h"

@implementation OPNUserEntry

#pragma mark - NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:_userName forKey:@"_userName"];
    [coder encodeObject:_password forKey:@"_password"];
    [coder encodeObject:_workgroup forKey:@"_workgroup"];
    [coder encodeObject:_remoteDirectory forKey:@"_remoteDirectory"];
    [coder encodeObject:_targetServer forKey:@"_targetServer"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self){
        _userName        = [decoder decodeObjectForKey:@"_userName"];
        _password        = [decoder decodeObjectForKey:@"_password"];
        _workgroup       = [decoder decodeObjectForKey:@"_workgroup"];
        _remoteDirectory = [decoder decodeObjectForKey:@"_remoteDirectory"];
        _targetServer    = [decoder decodeObjectForKey:@"_targetServer"];
    }
    return self;
}

#pragma mark - NSObject
- (NSString *)description
{
    return [NSString stringWithFormat:@"OPNUserEntry description:\n%@ userName: %@\npassword: %@\nworkgroup: %@\nremoteDirectory: %@\ntargetServer: %@\n",[super description], self.userName, self.password, self.workgroup, self.remoteDirectory, self.targetServer];
}
@end
