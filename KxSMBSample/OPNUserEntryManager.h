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

@property (nonatomic) NSMutableArray *userEntries;

+ (OPNUserEntryManager*)sharedManager;
- (void)addUserEntry:(OPNUserEntry*)userEntry;
- (void)insertUserEntry:(OPNUserEntry *)entry inUserEntriesAtIndex:(NSUInteger)index;
- (void)removeUserEntriy:(NSUInteger)index;
- (void)moveUserEntryAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)save;
- (void)reloadBookmarksWithBlock:(void (^)(NSError *error))block;

@end
