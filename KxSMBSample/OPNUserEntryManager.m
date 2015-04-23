//
//  OPNUserEntryManager.m
//  OPNFileReader
//
//  Created by Shota Takai on 2015/04/23.
//  Copyright (c) 2015年 NRI Netcom. All rights reserved.
//

#import "OPNUserEntryManager.h"

@implementation OPNUserEntryManager
+ (OPNUserEntryManager*)sharedManager
{
    static OPNUserEntryManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[OPNUserEntryManager alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.userEntries = @[];
    }
    return self;
}

- (void)addUserEntry:(OPNUserEntry*)userEntry {
}

- (void)insertUserEntry:(OPNUserEntry *)entry inUserEntriesAtIndex:(NSUInteger)index {
}

- (void)removeUserEntriy:(NSUInteger)index {
}

- (void)moveUserEntryAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
}

- (void)save {
}

- (void)reloadBookmarksWithBlock:(void (^)(NSError *error))block {
}

@end
