//
//  NSDictionary+SafeValue.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/09.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import "NSDictionary+SafeValue.h"

@implementation NSDictionary(SafeValue)
- (id)validValueForKey:(id)key
{
    if (!key) return nil;
    
    id value = nil;
    
    @try {
        value = [self valueForKeyPath:key];
    }
    @catch (NSException *exception) {
        if (exception) return nil;
    }
    
    if (!value) return nil;
    
    if (value != [NSNull null] && [value isKindOfClass:[NSString class]] && [value length] == 0) return nil;
    
    if (value == [NSNull null]) return nil;
    
    return value;
}

- (void)setValidValue:(id)value forKey:(id)key
{
    if (value && key && value != [NSNull null]) [self setValue:value forKey:key];
}

@end
