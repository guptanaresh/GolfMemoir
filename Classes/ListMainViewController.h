//
//  ListMainViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "GolfMemoirAppDelegate.h"

#define kADBannerView			70

@interface ListMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate>
{

	NSMutableArray			*scoreList;
	UITableView				*myTableView;
	GolfMemoirAppDelegate *deleg;
	BOOL bannerVisible;
	ADBannerView *banner;
}

@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) GolfMemoirAppDelegate *deleg;
@property (nonatomic, retain) NSMutableArray *scoreList;
@property (nonatomic, assign) BOOL bannerVisible;
@property (nonatomic, retain) ADBannerView *banner;

@end
