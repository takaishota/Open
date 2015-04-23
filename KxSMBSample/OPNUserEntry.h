//
//  OPNUserEntry.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/21.
//

#import <Foundation/Foundation.h>
#import "Server.h"

@interface OPNUserEntry : NSObject <NSCoding>
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *workgroup;
@property (nonatomic) NSString *remoteDirectory;
@property (nonatomic) Server *targetServer;
@end
