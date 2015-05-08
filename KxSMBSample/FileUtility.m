//
//  FileUtility.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/26.
//

#import "FileUtility.h"

@implementation FileUtility

static FileUtility *_sharedInstance = nil;
+ (FileUtility *)sharedUtility {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FileUtility alloc] init];
    });
    return _sharedInstance;
}

- (NSString*)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    return [paths objectAtIndex:0];
}

- (NSString*)documentDirectoryWithFileName:(NSString*)fileName {
    return [[self documentDirectory] stringByAppendingPathComponent:fileName];
}

- (NSArray*)fileNamesAtDirectoryPath:(NSString*)directoryPath extension:(NSString*)extension {
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

- (BOOL)removeFileAtPath:(NSString *)path {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    return [fileManager removeItemAtPath:path error:nil];;
}

-(BOOL)resetLocalDocumentsDirectory {
    NSFileManager *fileManager=[[NSFileManager alloc] init];
    BOOL result = [fileManager removeItemAtPath:[self documentDirectory] error:nil];
    result      = [fileManager createDirectoryAtPath:[self documentDirectory] withIntermediateDirectories:NO attributes:nil error:nil];
    return result;
}

@end
