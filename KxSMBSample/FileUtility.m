//
//  FileUtility.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/26.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import "FileUtility.h"

@implementation FileUtility

static FileUtility *_sharedInstance = nil;
+ (FileUtility *)sharedUtility
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FileUtility alloc] init];
    });
    return _sharedInstance;
}

- (NSString*)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    return [paths objectAtIndex:0];
}

- (NSArray*)fileNamesAtDirectoryPath:(NSString*)directoryPath extension:(NSString*)extension
{
    NSFileManager *fileManager=[[NSFileManager alloc] init];
    NSError *error = nil;
    /* 全てのファイル名 */
    NSArray *allFileName = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
    if (error) return nil;
    if (!extension) return allFileName;
    
    NSMutableArray *hitFileNames = [[NSMutableArray alloc] init];
    for (NSString *fileName in allFileName) {
        /* 拡張子が一致するか */
        if ([[fileName pathExtension] isEqualToString:extension]) {
            [hitFileNames addObject:fileName];
        }
    }
    return hitFileNames;
}

@end