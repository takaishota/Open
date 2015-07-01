//
//  OPNSearchResultTableViewController.h
//  OPNFileReader
//
//  Created by Shota Takai on 2015/05/28.
//  Copyright (c) 2015年 NRI Netcom. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OPNSearchResultTableViewController, KxSMBItem;

@protocol OPNSearchResultTableViewControllerDelegate <NSObject>
@optional
- (void)searchResultView:(OPNSearchResultTableViewController *)searchResultView didSelectItem:(KxSMBItem *)item;
@end

@interface OPNSearchResultTableViewController : UITableViewController
@property NSMutableArray *searchResults;
@property (nonatomic, weak) id <OPNSearchResultTableViewControllerDelegate> delegate;
@end
