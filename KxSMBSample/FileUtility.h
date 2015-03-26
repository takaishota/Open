//
//  FileUtility.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/26.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtility : NSObject

+ (FileUtility *)sharedUtility;
- (NSString*)documentDirectory;
- (NSArray*)fileNamesAtDirectoryPath:(NSString*)directoryPath extension:(NSString*)extension;

@end
