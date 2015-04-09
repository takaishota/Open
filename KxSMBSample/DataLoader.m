//
//  DataLoader.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/07.
//

#import "DataLoader.h"
// :: Other ::
#import "NSDictionary+SafeValue.h"
#import "NSJSONSerialization+JSONFile.h"
#import "Server.h"

NSString *const NETWORKTYPE_LAN = @"LAN";
NSString *const NETWORKTYPE_CLOUD = @"CLOUD";
NSString *const NETWORKTYPE_PUBLIC = @"PUBLIC";

@interface DataLoader ()
@property (nonatomic) NSArray *JSON;

@end

@implementation DataLoader
- (instancetype)initWithJSONFile:(NSString*)fileName
{
    self = [super init];
    if (!self) return nil;
    _JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:fileName];
    
    [self generateFormsWithJSON:_JSON];
    
    return self;
}

- (void)generateFormsWithJSON:(id)JSON {
    NSArray *servers = [NSMutableArray array];
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    if ([JSON isKindOfClass:[NSArray class]]) {
        servers = JSON;
    } else if ([JSON isKindOfClass:[NSDictionary class]]) {
        servers = [JSON valueForKey:@"servers"];
        
        __block id networkType;
        [servers enumerateObjectsUsingBlock:^(NSDictionary *serverDictionary, NSUInteger idx, BOOL *stop) {
            Server *server = [Server new];
            NSString *serverIp = [serverDictionary validValueForKey:@"ip"];
            if (serverIp) {
                server.ip = serverIp;
            }
            
            networkType = [serverDictionary validValueForKey:@"network-type"];
            if ([networkType isEqualToString:NETWORKTYPE_LAN]) {
                server.networkType = NETWORKTYPE_LAN;
            } else if([networkType isEqualToString:NETWORKTYPE_PUBLIC]) {
                server.networkType = NETWORKTYPE_PUBLIC;
            } else if ([networkType isEqualToString:NETWORKTYPE_CLOUD]) {
                server.networkType = NETWORKTYPE_CLOUD;
            }
            
            [tmpArray addObject:server];
        }];
        
    } else {
        NSLog(@"Not a valid JSON format");
        abort();
    }
    self.serverList = tmpArray;
}

@end
