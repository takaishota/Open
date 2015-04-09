//
//  DataLoader.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/07.
//

#import <Foundation/Foundation.h>

@interface DataLoader : NSObject
@property (nonatomic) NSMutableArray *serverList;

- (instancetype)initWithJSONFile:(NSString*)fileName;

@end