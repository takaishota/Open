//
//  OPNUserEntryManager.h
//  OPNFileReader
//
//  Created by Shota Takai on 2015/04/23.
//  Copyright (c) 2015年 NRI Netcom. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OPNUserEntry;

@interface OPNUserEntryManager : NSObject

@property (nonatomic) OPNUserEntry *lastUserEntry;
@property (nonatomic) NSMutableArray *userEntries;

+ (OPNUserEntryManager*)sharedManager;
- (void)addUserEntry:(OPNUserEntry*)userEntry;
- (void)updateUserEntry:(OPNUserEntry*)entry inUserEntriesAtIndex:(NSUInteger)index;
- (void)insertUserEntry:(OPNUserEntry *)entry inUserEntriesAtIndex:(NSUInteger)index;
- (void)removeUserEntry:(NSUInteger)index;
- (void)removeAllUserEntries;
- (void)moveUserEntryAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (NSString*)getServerIpAtIndex:(NSUInteger)index;
- (NSString*)getEntryName:(NSUInteger)index;

@end
