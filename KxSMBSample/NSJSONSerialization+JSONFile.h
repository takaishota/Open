//
//  NSJSONSerialization+JSONFile.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/08.
//

#import <Foundation/Foundation.h>
@interface NSJSONSerialization (JSONFile)

+ (id)JSONObjectWithContentsOfFile:(NSString*)fileName inBundle:(NSBundle *)bundle;

+ (id)JSONObjectWithContentsOfFile:(NSString*)fileName;

@end
