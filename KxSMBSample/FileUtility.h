//
//  FileUtility.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/26.
//

#import <Foundation/Foundation.h>

@interface FileUtility : NSObject

+ (FileUtility *)sharedUtility;
- (NSString*)documentDirectory;
- (NSString*)documentDirectoryWithFileName:(NSString*)fileName;
- (NSArray*)fileNamesAtDirectoryPath:(NSString*)directoryPath extension:(NSString*)extension;
- (BOOL)removeFileAtPath:(NSString *)path;
- (BOOL)resetLocalDocumentsDirectory;

@end
