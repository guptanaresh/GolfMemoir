//
//  FVMainViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameFriendsViewController.h"
#import "CourseTable.h"
#import "Course.h"
#import <iAd/iAd.h>
#import <StoreKit/SKProductsRequest.h>

#define kCourseTableViewTag	1
#define kAddCourseButtonViewTag	2
#define kTeeTypeViewTag	3
#define kGameTypeViewTag	4
#define kScoreTypeViewTag	5

#define kADBannerView			70

#define kDateEnterString @"Set Date"

@interface GameMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate>
{
	GameFriendsViewController *holeController;
	UITableView		*tView;
	UISegmentedControl		*sView;
	UISegmentedControl		*gView;
	NSMutableArray			*courseList;
	GolfMemoirAppDelegate *deleg;
	NSInteger currentSelection;
	NSInteger	myTeeType;
	NSInteger	myGameType;
	NSInteger	myScoreType;
	UIButton *bView;
	UIDatePicker *datePickerView;
	NSDate *myDate;
	UIBarButtonItem *startButton;
	UIBarButtonItem *changeButton;
	UISegmentedControl *scoreTypeView;
	BOOL bannerVisible;
	ADBannerView *banner;
}

@property (nonatomic, assign) UISegmentedControl		*sView;
@property (nonatomic, assign) UISegmentedControl		*gView;
@property (nonatomic, assign) UISegmentedControl		*scoreTypeView;
@property (nonatomic, assign) UITableView *tView;
@property (nonatomic, assign) NSDate *myDate;
@property (nonatomic, assign) NSMutableArray *courseList;
@property (nonatomic, assign) GolfMemoirAppDelegate *deleg;
@property (nonatomic, assign) NSInteger currentSelection;
@property (nonatomic, assign) NSInteger	myTeeType;
@property (nonatomic, assign) NSInteger	myGameType;
@property (nonatomic, assign) NSInteger	myScoreType;
@property (nonatomic, assign) BOOL bannerVisible;
@property (nonatomic, assign) ADBannerView *banner;

- (void)gameDateAction:(id)sender;
- (void)startGameAction:(id)sender;
- (void)hideDatePicker;
-(void)refreshView;

@end
