//
//  OPNUserEntry.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/21.
//

#import "OPNUserEntry.h"

@implementation OPNUserEntry {
    NSString *_entry;
}

#pragma mark - NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_entry forKey:@"entry"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self){
        _entry = [aDecoder decodeObjectForKey:@"entry"];
    }
    return self;
}

#pragma mark - NSObject
- (NSString *)description
{
    return [NSString stringWithFormat:@"OPNUserEntry description:\n%@ userName: %@\npassword: %@\nworkgroup: %@\nremoteDirectory: %@\ntargetServer: %@\n",[super description], self.userName, self.password, self.workgroup, self.remoteDirectory, self.targetServer];
}
@end
