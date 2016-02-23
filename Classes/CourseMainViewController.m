//
//  ListMainViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import "CourseMainViewController.h"
#import "EditCourseController.h"
#import "DownloadViewController.h"
#import "Constants.h"
#import "Reachability.h"


@implementation CourseMainViewController

@synthesize myTableView, courseList, deleg, bannerVisible, banner;

static NSString *kCellIdentifier = @"CourseViewIdentifier";

- (id)init
{
	if (self = [super init])
	{
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Courses", @"");
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
	}
	return self;
}


- (void)loadView
{
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"CourseMain" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];

	myTableView = (UITableView *)[cView viewWithTag:kCourseTableViewTag];
	myTableView.delegate=self;
	myTableView.dataSource=self;
	
	banner = (ADBannerView *)[cView viewWithTag:kADBannerView];
	banner.delegate=self;
	bannerVisible=TRUE;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: @"Download", 
								   @"Add",
								   nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.backgroundColor=[UIColor clearColor];
	
	[segmentedControl addTarget:self action:@selector(courseMainAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 140, kCustomButtonHeight);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;

	/*
	 UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithTitle:NSLocalizedString(@"Add A New Course", @"") style:UIBarButtonItemStyleBordered
								  target:self action:@selector(addCourseButtonAction:)];
	 self.navigationItem.rightBarButtonItem = addButton;
	 */

	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}


- (void)dealloc
{
	banner.delegate=nil;

	[courseList release];
	[myTableView release];
	
	[super dealloc];
}

- (void)courseMainAction:(id)sender
{
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Can't download course information because there is no internet connection available."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
		else{
			UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[DownloadViewController alloc] init]];
			[self presentViewController:dViewC animated:TRUE completion:nil];
			[dViewC release];
		}
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 1){
		[self addCourseButtonAction:sender];
	}
}	

#pragma mark UIViewController delegate methods
- (void)addCourseButtonAction:(id)sender
{
	UIViewController *targetViewController = [[EditCourseController alloc] initWithCourse:nil];
	[[self navigationController] pushViewController:targetViewController animated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [myTableView indexPathForSelectedRow];
	[myTableView deselectRowAtIndexPath:tableSelection animated:NO];
	self.courseList = [Course retrieveAllCourses:deleg.database];
	[myTableView reloadData];
}


#pragma mark UITableView delegate methods

// tell our table how many sections or groups it will have (always 1 in our case)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UIViewController *targetViewController = [[EditCourseController alloc] initWithCourse:[courseList objectAtIndex: indexPath.row]];
	[[self navigationController] pushViewController:targetViewController animated:YES];
}


#pragma mark UITableView datasource methods

// tell our table how many rows it will have, in our case the size of our courseList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [courseList count];
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
	}
	
	Course	*aCourse = [courseList objectAtIndex:indexPath.row];
	cell.textLabel.text = aCourse.courseName;
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

#pragma mark -
#pragma mark ADBannerViewDelegate methods
- (void)bannerViewDidLoadAd:(ADBannerView *)cbanner
{
	
    if (!self.bannerVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        //banner.hidden = NO;
		// assumes the banner view is offset 50 pixels so that it is not visible.
        cbanner.frame = CGRectOffset(cbanner.frame, 0, 50);
		bannerVisible=TRUE;
        [UIView commitAnimations];
    }
}
- (void)bannerView:(ADBannerView *)cbanner didFailToReceiveAdWithError:(NSError *)error
{
	if (self.bannerVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
        cbanner.frame = CGRectOffset(cbanner.frame, 0, -50);
		//banner.hidden = TRUE;
		self.bannerVisible=FALSE;
        [UIView commitAnimations];
    }
}



@end