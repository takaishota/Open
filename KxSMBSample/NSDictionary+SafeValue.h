//
//  NSDictionary+SafeValue.h
//  SMBFileReader
//
//  Created by Shota Takai on 2015/04/09.
//  Copyright (c) 2015年 Konstantin Bukreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(SafeValue)
- (id)validValueForKey:(id)key;
- (void)setValidValue:(id)value forKey:(id)key;

@end