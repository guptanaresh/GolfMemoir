//
//  ListMainViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GolfMemoirAppDelegate.h"
#import "GameFriendPicker.h"
#import <iAd/iAd.h>



#define kFriendTableViewTag	1
#define kADBannerView			70

@interface GameFriendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate>
{
	GameHoleViewController *holeController;
	NSMutableArray			*playerList;
	UITableView				*myTableView;
	GolfMemoirAppDelegate *deleg;
	BOOL bannerVisible;
	ADBannerView *banner;
}

@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) GolfMemoirAppDelegate *deleg;
@property (nonatomic, retain) NSMutableArray *playerList;
@property (nonatomic, assign) BOOL bannerVisible;
@property (nonatomic, retain) ADBannerView *banner;

@end
