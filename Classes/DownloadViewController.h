//
//  DownloadViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GolfMemoirAppDelegate.h"
	
	
#define kCourseTableViewTag	1
#define kSearchBarViewTag	2
	
@interface DownloadViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIAlertViewDelegate>
{
	
	UITableView				*myTableView;
	GolfMemoirAppDelegate *deleg;
	UISearchBar				*searchBar;
	NSArray			*courseList;
	NSArray			*courseIDs;
	UIAlertView		*errorAlert;
	UIAlertView *dupalert;
	NSIndexPath	*currentSelection;
}

@property (nonatomic, retain) UISearchBar				*searchBar;
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, assign) GolfMemoirAppDelegate *deleg;
@property (nonatomic, copy) NSArray *courseList;
@property (nonatomic, copy) NSArray *courseIDs;
@property (nonatomic, assign) NSIndexPath	*currentSelection;

- (void)downloadCourse:(NSInteger)courseID;

@end
