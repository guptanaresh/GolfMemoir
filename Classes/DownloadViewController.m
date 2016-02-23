//
//  DownloadViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DownloadViewController.h"
#import "EditCourseController.h"
#import "Constants.h"


@implementation DownloadViewController

@synthesize myTableView, deleg, courseList,courseIDs, searchBar, currentSelection;

static NSString *kCellIdentifier = @"CourseDownloadIdentifier";

- (id)init
{
	if (self = [super init])
	{
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Internet Download", @"");
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		courseList=[[NSArray alloc] init];
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
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"DownloadCourse" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	myTableView = (UITableView *)[cView viewWithTag:kCourseTableViewTag];
	myTableView.delegate=self;
	myTableView.dataSource=self;
	
	searchBar = (UISearchBar *)[cView viewWithTag:kSearchBarViewTag];
	searchBar.delegate=self;
	
	//[self searchBarSearchButtonClicked:searchBar];
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: @"Download", @"Cancel", 
								   nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.backgroundColor=[UIColor clearColor];
	
	[segmentedControl addTarget:self action:@selector(courseMainAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 120, kCustomButtonHeight);
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
	[courseList release];
	[courseIDs release];
	[myTableView release];
	
	[super dealloc];
}

- (void)courseMainAction:(id)sender
{
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		NSIndexPath* index=currentSelection;
		if(index != nil){
			NSString *cName=[courseList objectAtIndex:index.row];
			NSInteger pk = [Course retrieveCourse:deleg.database name:cName];
			if(pk != -1){
				dupalert = [[UIAlertView alloc] initWithTitle:@"Course Exists" message:@"Would you like to replace the current course information on your device."
															   delegate:self cancelButtonTitle:@"Replace" otherButtonTitles: @"No", nil];
				[dupalert show];
				[dupalert release];
			}
			else{
				NSNumber *num=[courseIDs objectAtIndex:index.row];
				[self downloadCourse:[num integerValue]];
				[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
			}
		}
		else{
			// open an alert with just an OK button
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pick A Course" message:@"Please select a course from the list."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];
		}
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 1){
		[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
	}
	
}	

- (void)downloadCourse:(NSInteger)courseID                  // called when keyboard search button pressed
{
	NSString *tx= [NSString stringWithFormat:@"http://www.golfmemoir.com/course_download.php?courseID=%i", courseID];
	
	NSURL *url = [NSURL URLWithString:tx]; 
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLResponse *response;
	NSError *error;
	NSData *plistData;
	plistData = [NSURLConnection sendSynchronousRequest:request
									  returningResponse:&response error:&error];
	
	NSString *str = [[NSString alloc] initWithData:plistData encoding:NSASCIIStringEncoding];
	NSLog(@"%@", str);
	
	// parse the HTTP response into a plist
	NSPropertyListFormat format;
	id plist;
	NSString *errorStr;
	plist = [NSPropertyListSerialization propertyListFromData:plistData
											 mutabilityOption:NSPropertyListImmutable
													   format:&format
											 errorDescription:&errorStr];
	if(!plist) {
		NSLog(@"%@", errorStr);
		[error release];
	} else {
		NSString *cName=[[plist objectForKey:@"courseName"] copy];
		
		NSInteger pk = [Course retrieveCourse:deleg.database name:cName];
		if(pk == -1){
			pk=[Course insertNewCourseIntoDatabase:deleg.database];
		}
		Course *aCourse = [[Course alloc] initWithPrimaryKey:pk database:deleg.database];
		aCourse.courseName = cName;
		if(aCourse.courseAddress == nil || [aCourse.courseAddress length] <=0){
			aCourse.courseAddress=[[plist objectForKey:@"courseAddress"] copy];
		}
		if(aCourse.courseCity == nil || [aCourse.courseCity length] <=0){
			aCourse.courseCity=[[plist objectForKey:@"courseCity"] copy];
		}
		if(aCourse.courseState == nil || [aCourse.courseState length] <=0){
			aCourse.courseState=[[plist objectForKey:@"courseState"] copy];
		}
		if(aCourse.courseCountry == nil || [aCourse.courseCountry length] <=0){
			aCourse.courseCountry=[[plist objectForKey:@"courseCountry"] copy];
		}
		if(aCourse.coursePhone == nil || [aCourse.coursePhone length] <=0){
			aCourse.coursePhone=[[plist objectForKey:@"coursePhone"] copy];
		}
		if(aCourse.courseWebsite == nil || [aCourse.courseWebsite length] <=0){
			aCourse.courseWebsite=[[plist objectForKey:@"courseWebsite"] copy];
		}
		if(aCourse.courseZipcode == nil || [aCourse.courseZipcode length] <=0){
			aCourse.courseZipcode=[[plist objectForKey:@"courseZipcode"] copy];
		}

		double aRate=[[plist objectForKey:@"whiteRate"] doubleValue];
		if( aRate!= 0){
			aCourse.whiteRate=aRate;
		}
		aRate=[[plist objectForKey:@"blackRate"] doubleValue];
		if( aRate!= 0){
			aCourse.blackRate=aRate;
		}
		 aRate=[[plist objectForKey:@"blueRate"] doubleValue];
		if( aRate!= 0){
			aCourse.blueRate=aRate;
		}
		 aRate=[[plist objectForKey:@"orangeRate"] doubleValue];
		if( aRate!= 0){
			aCourse.orangeRate=aRate;
		}
		NSInteger aSlope=[[plist objectForKey:@"whiteSlope"] intValue];
		if( aSlope!= 0){
			aCourse.whiteSlope=aSlope;
		}
		 aSlope=[[plist objectForKey:@"blackSlope"] intValue];
		if( aSlope!= 0){
			aCourse.blackSlope=aSlope;
		}
		 aSlope=[[plist objectForKey:@"blueSlope"] intValue];
		if( aSlope!= 0){
			aCourse.blueSlope=aSlope;
		}
		 aSlope=[[plist objectForKey:@"orangeSlope"] intValue];
		if( aSlope!= 0){
			aCourse.orangeSlope=aSlope;
		}
		
		[aCourse toDB];

		NSArray *whiteParArray=[[plist objectForKey:@"whitePar"] copy];
		NSArray *blackYardArray=[[plist objectForKey:@"blackYard"] copy];
		NSArray *blueYardArray=[[plist objectForKey:@"blueYard"] copy];
		NSArray *whiteYardArray=[[plist objectForKey:@"whiteYard"] copy];
		NSArray *orangeYardArray=[[plist objectForKey:@"orangeYard"] copy];
		NSArray *hcpArray=[[plist objectForKey:@"hcp"] copy];
		NSArray *latitudeArray=[[plist objectForKey:@"latitude"] copy];
		NSArray *longitudeArray=[[plist objectForKey:@"longitude"] copy];
		NSArray *holeTypeArray=[[plist objectForKey:@"holeType"] copy];
		NSArray *teeLatitudeArray=[[plist objectForKey:@"teeLatitude"] copy];
		NSArray *teeLongitudeArray=[[plist objectForKey:@"teeLongitude"] copy];
		NSArray *frontLatitudeArray=[[plist objectForKey:@"frontLatitude"] copy];
		NSArray *frontLongitudeArray=[[plist objectForKey:@"frontLongitude"] copy];
		NSArray *backLatitudeArray=[[plist objectForKey:@"backLatitude"] copy];
		NSArray *backLongitudeArray=[[plist objectForKey:@"backLongitude"] copy];

		BOOL updatePar=TRUE;
/*		for(int i=1; i <=18; i++){
			aCourse.holeNumber=i;
			if(aCourse.curHole.whitePar != kInitialParValue){
				updatePar=FALSE;
				break;
			}
		}
*/		
		for(int i=1; i <=18; i++){
			aCourse.holeNumber=i;
			if([whiteParArray objectAtIndex:i-1]){
				NSInteger wPar = [[whiteParArray objectAtIndex:i-1] intValue];
				if(updatePar == TRUE && wPar != 0) 
					aCourse.curHole.whitePar = wPar;
			}
			if([blackYardArray objectAtIndex:i-1])
				aCourse.curHole.blackYard = [[blackYardArray objectAtIndex:i-1]intValue];
			if([blueYardArray objectAtIndex:i-1])
				aCourse.curHole.blueYard = [[blueYardArray objectAtIndex:i-1] intValue];
			if([whiteYardArray objectAtIndex:i-1])
				aCourse.curHole.whiteYard = [[whiteYardArray objectAtIndex:i-1] intValue];
			if([orangeYardArray objectAtIndex:i-1])
				aCourse.curHole.orangeYard = [[orangeYardArray objectAtIndex:i-1] intValue];
			if([hcpArray objectAtIndex:i-1])
				aCourse.curHole.hcp = [[hcpArray objectAtIndex:i-1] intValue];
			if([latitudeArray objectAtIndex:i-1])
				aCourse.curHole.latitude = [((NSString *)[latitudeArray objectAtIndex:i-1]) doubleValue];
			if([longitudeArray objectAtIndex:i-1])
				aCourse.curHole.longitude = [((NSString *)[longitudeArray objectAtIndex:i-1]) doubleValue];
			if([holeTypeArray objectAtIndex:i-1])
				aCourse.curHole.holeType = [[holeTypeArray objectAtIndex:i-1] intValue];
			if([teeLatitudeArray objectAtIndex:i-1])
				aCourse.curHole.teeLatitude = [((NSString *)[teeLatitudeArray objectAtIndex:i-1]) doubleValue];
			if([teeLongitudeArray objectAtIndex:i-1])
				aCourse.curHole.teeLongitude = [((NSString *)[teeLongitudeArray objectAtIndex:i-1]) doubleValue];
			if([frontLatitudeArray objectAtIndex:i-1])
				aCourse.curHole.frontLatitude = [((NSString *)[frontLatitudeArray objectAtIndex:i-1]) doubleValue];
			if([frontLongitudeArray objectAtIndex:i-1])
				aCourse.curHole.frontLongitude = [((NSString *)[frontLongitudeArray objectAtIndex:i-1]) doubleValue];
			if([backLatitudeArray objectAtIndex:i-1])
				aCourse.curHole.backLatitude = [((NSString *)[backLatitudeArray objectAtIndex:i-1]) doubleValue];
			if([backLongitudeArray objectAtIndex:i-1])
				aCourse.curHole.backLongitude = [((NSString *)[backLongitudeArray objectAtIndex:i-1]) doubleValue];
			[aCourse.curHole toDB];
		}
		
	}
	
	
}

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchB                  // called when keyboard search button pressed
{
	BOOL noCourse=FALSE;
	id plist=[Course searchCoursesFromInternet:searchB.text];
	if(!plist) {
		noCourse=TRUE;
	} else {
		
		// access elements from inside the plist
		
		courseList = [[plist objectForKey:@"courseName"] copy];
		courseIDs = [[plist objectForKey:@"courseID"] copy];
		[myTableView reloadData];
		if([courseIDs count] <= 0)
			noCourse=TRUE;
	}
	
	[searchB resignFirstResponder];

	//noCourse=FALSE;
	if(noCourse){
		errorAlert = [[UIAlertView alloc] initWithTitle:@"Course Not Found" message:@"Please search for another course or create the course manually by clicking the Add button."
													   delegate:self cancelButtonTitle:@"Add" otherButtonTitles: @"Search", nil];
		[errorAlert show];
		[errorAlert release];
	}
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView == errorAlert){
		if(buttonIndex == 1){
			[searchBar becomeFirstResponder];
		}
		else if(buttonIndex == 0){
			UIViewController *vc=[self parentViewController];
			[vc dismissViewControllerAnimated:YES completion:nil];
		}
	} 
	else if(alertView == dupalert){
		if(buttonIndex == 0){
			NSIndexPath* index=currentSelection;
			if(index != nil){
				NSNumber *num=[courseIDs objectAtIndex:index.row];
				[self downloadCourse:[num integerValue]];
			}
			[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
		}

	}
}
#pragma mark UIViewController delegate methods


- (void)viewWillAppear:(BOOL)animated
{
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = currentSelection;
	if(currentSelection)
	[myTableView deselectRowAtIndexPath:tableSelection animated:NO];
	//self.courseList = [Course retrieveAllCourses:deleg.database];
	[myTableView reloadData];
}


#pragma mark UITableView delegate methods


// tell our table how many sections or groups it will have (always 1 in our case)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	NSIndexPath *oldIndex = currentSelection;
	if(oldIndex != nil){
		UITableViewCell *oldCell = [theTableView cellForRowAtIndexPath:oldIndex];
		oldCell.accessoryType=UITableViewCellAccessoryNone;
	}
	[theTableView deselectRowAtIndexPath:newIndexPath animated:YES];
    UITableViewCell *newCell = [theTableView cellForRowAtIndexPath:newIndexPath];
	newCell.accessoryType = UITableViewCellAccessoryCheckmark;
	currentSelection = newIndexPath;
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
	
	NSString	*aCourse = [self.courseList objectAtIndex:indexPath.row];
	cell.textLabel.text = aCourse;
	
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

@end