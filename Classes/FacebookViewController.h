//
//  ContactTable.h
//  GolfMemoir
//
//  Created by naresh gupta on 6/7/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBConnect/FBConnect.h>
#import "GolfMemoirAppDelegate.h"
#import "Constants.h"

#define kFBViewTag			1

@interface FacebookViewController : UIViewController<FBSessionDelegate, FBRequestDelegate, UITableViewDataSource, UITableViewDelegate> {
	NSMutableArray *fbFriends;
	NSMutableArray *fbFriendsUID;
	UITableView			*fTableView;
	FBUID				fbuid;
	NSInteger			playerNumber;
	GolfMemoirAppDelegate *deleg;
	NSIndexPath	*currentSelection;
}


- (id)init:(NSInteger)playerNo;
- (NSString *)stringValueForRow:(NSInteger)row;
- (NSArray *)getAllPeople;	

@end
