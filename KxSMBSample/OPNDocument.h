//
//  OPNDocument.h
//  OPNFileReader
//
//  Created by Shota Takai on 2015/04/23.
//  Copyright (c) 2015年 NRI Netcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPNDocument : NSObject
@property (nonatomic) NSString *path;
@property (nonatomic) NSString *entryName;
@property (nonatomic) NSString *fileName;
@property (nonatomic) NSString *fileSize;
@property (nonatomic) NSString *contentType;
@property (nonatomic) NSString *createdAt;
@property (nonatomic) NSString *updatedAt;
@end
