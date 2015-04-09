//
//  NSJSONSerialization+JSONFile.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/08.
//

#import "NSJSONSerialization+JSONFile.h"

@implementation NSJSONSerialization (JSONFile)

+ (id)JSONObjectWithContentsOfFile:(NSString*)fileName
{
    return [self JSONObjectWithContentsOfFile:fileName inBundle:[NSBundle mainBundle]];
}

+ (id)JSONObjectWithContentsOfFile:(NSString*)fileName inBundle:(NSBundle *)bundle
{
    NSString *filePath = [bundle pathForResource:[fileName stringByDeletingPathExtension]
                                          ofType:[fileName pathExtension]];
    
    NSAssert(filePath, @"JSONFile: File not found");
    NSLog(@"filePath: %@",filePath);
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    NSError *error = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    
    if (error) NSLog(@"JSONFile error: %@", error);
    
    if (error != nil) return nil;
    
    return result;
}

@end
