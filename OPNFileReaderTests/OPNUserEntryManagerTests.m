//
//  OPNUserEntryManagerTests.m
//  OPNFileReader
//
//  Created by Shota Takai on 2015/05/01.
//  Copyright (c) 2015年 NRI Netcom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OPNUserEntry.h"
#import "OPNUserEntryManager.h"
#import "Server.h"

@interface OPNUserEntryManagerTests : XCTestCase

@end

@implementation OPNUserEntryManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

// エントリの追加処理のテスト
- (void)testAddUserEntry {
    
    OPNUserEntry *entry = [OPNUserEntry new];
    entry.userName = @"s-takai";
    entry.password = @"testPass";
    entry.workgroup = @"workgroup";
    entry.remoteDirectory = @"/c0120/個人フォルダ/s-takai";
    entry.targetServer = [[Server alloc] initWithIp:@"172.18.34.230" NetworkType:@"LAN"];
    
    
    NSUInteger userEntriesCountForBeforeTest = [[OPNUserEntryManager sharedManager].userEntries count];
    
    // TODO:Mockに変更する
    [[OPNUserEntryManager sharedManager] addUserEntry:entry];
    
    XCTAssertEqual(userEntriesCountForBeforeTest + 1, [[OPNUserEntryManager sharedManager].userEntries count], "ユーザエントリ数が一致していません");
}

@end
