//
//  Server.h
//  SMBFileReader
//
//  Created by ShotaTakai on 2015/04/05.
//

#import <Foundation/Foundation.h>

@interface Server : NSObject
@property (nonatomic) NSString *ip;
@property (nonatomic) NSString* networkType;
- (id) initWithIp:(NSString*)ip NetworkType:(NSString*)type;
@end
