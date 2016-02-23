//
//  ListMainViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GolfMemoirAppDelegate.h"
#import <iAd/iAd.h>//;


#define kCourseTableViewTag	1
#define kAddCourseButtonViewTag	2
#define kADBannerView			70

@interface CourseMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate>
{

	NSMutableArray			*courseList;
	UITableView				*myTableView;
	GolfMemoirAppDelegate *deleg;
	BOOL bannerVisible;
	ADBannerView *banner;
}

@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, assign) GolfMemoirAppDelegate *deleg;
@property (nonatomic, assign) NSMutableArray *courseList;
@property (nonatomic, assign) BOOL bannerVisible;
@property (nonatomic, retain) ADBannerView *banner;

@end
