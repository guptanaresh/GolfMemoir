//
//  FVMainViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import "GameMainViewController.h"
#import "UnlockWebViewController.h"
#import "GolfMemoirAppDelegate.h"
#import "Constants.h"
#import "EditCourseController.h"
#import <AddressBook/ABPerson.h>
#import <StoreKit/SKPaymentQueue.h>
#import <iAd/ADBannerView.h>
#import "PayObserver.h"

@implementation GameMainViewController
static NSString *kCellIdentifier = @"MainCourseViewIdentifier";

@synthesize tView, deleg, courseList, sView, currentSelection, myTeeType, gView, myGameType, myDate, myScoreType, scoreTypeView, bannerVisible, banner;


#define kStdButtonWidth 150

- (id)init
{
	if (self = [super init])
	{
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Pick Course", @"");
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
	}
	return self;
}

- (void)dealloc
{
	banner.delegate=nil;
	[courseList release];
	[super dealloc];
}

- (void)loadView
{
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];

	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"GameMainView" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	banner = (ADBannerView *)[cView viewWithTag:kADBannerView];
	banner.delegate = (id<ADBannerViewDelegate>)self;
	bannerVisible=TRUE;
	
	tView = (UITableView *)[cView viewWithTag:kCourseTableViewTag];
	tView.delegate=self;
	tView.dataSource=self;

	bView = (UIButton *)[cView viewWithTag:kAddCourseButtonViewTag];
	[bView addTarget:self action:@selector(addCourseButtonAction:) forControlEvents:UIControlEventTouchUpInside];

	
	
	sView = (UISegmentedControl *)[cView viewWithTag:kTeeTypeViewTag];
	[sView addTarget:self action:@selector(teeTypeAction:) forControlEvents:UIControlEventValueChanged];
	gView = (UISegmentedControl *)[cView viewWithTag:kGameTypeViewTag];
	[gView addTarget:self action:@selector(gameTypeAction:) forControlEvents:UIControlEventValueChanged];
	scoreTypeView = (UISegmentedControl *)[cView viewWithTag:kScoreTypeViewTag];
	[scoreTypeView addTarget:self action:@selector(scoreTypeAction:) forControlEvents:UIControlEventValueChanged];
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
		
	// add our custom add button as the nav bar's custom right view
	 startButton = [[UIBarButtonItem alloc]
	 initWithTitle:NSLocalizedString(@"Start Game", @"") style:UIBarButtonItemStyleBordered
	 target:self action:@selector(startGameAction:)];
	 self.navigationItem.rightBarButtonItem = startButton;
	
	myDate=[[NSDate alloc] init];
	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	dateFormat.dateStyle = kCFDateFormatterShortStyle;
	NSString *dt = [dateFormat stringFromDate:myDate];
	[dateFormat release];

	changeButton = [[UIBarButtonItem alloc]
	 initWithTitle:dt style:UIBarButtonItemStyleBordered
	 target:self action:@selector(gameDateAction:)];
	 self.navigationItem.leftBarButtonItem = changeButton;
	 
								  
	currentSelection = -1;

}

- (void)teeTypeAction:(id)sender
{
	[self hideDatePicker];
	UISegmentedControl *ctrl = (UISegmentedControl *)sender;
	//[ctrl setImage:[UIImage imageNamed:@"segment_check.png" ] forSegmentAtIndex:ctrl.selectedSegmentIndex];
	if(ctrl.selectedSegmentIndex==0){
		myTeeType=kBlackTee;
	}
	else if(ctrl.selectedSegmentIndex ==1){
		myTeeType=kBlueTee;
	}
	else if(ctrl.selectedSegmentIndex ==2){
		myTeeType=kWhiteTee;
	}
	else if(ctrl.selectedSegmentIndex ==3){
		myTeeType=kRedTee;
	}
}
- (void)gameTypeAction:(id)sender
{
	[self hideDatePicker];
	UISegmentedControl *ctrl = (UISegmentedControl *)sender;
	myGameType=ctrl.selectedSegmentIndex;
	
}
- (void)scoreTypeAction:(id)sender
{
	[self hideDatePicker];
	UISegmentedControl *ctrl = (UISegmentedControl *)sender;
	myScoreType=ctrl.selectedSegmentIndex;
	
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
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
	NSInteger oldIndex = currentSelection;
    if (oldIndex == indexPath.row) {
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldIndex inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        currentSelection = indexPath.row;
    }
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
	[self hideDatePicker];
}
/*
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	NSInteger oldIndex = currentSelection;
	if(oldIndex != -1){
        NSIndexPath *oldPath=[ NSIndexPath indexPathWithIndex:oldIndex];
		UITableViewCell *oldCell = [theTableView cellForRowAtIndexPath:oldPath];
		oldCell.accessoryType=UITableViewCellAccessoryNone;
	}
	[theTableView deselectRowAtIndexPath:newIndexPath animated:YES];
    UITableViewCell *newCell = [theTableView cellForRowAtIndexPath:newIndexPath];
	newCell.accessoryType = UITableViewCellAccessoryCheckmark;
	currentSelection = newIndexPath.row;
	//currentSelection = [[ NSIndexPath alloc] initWithIndex:newIndexPath.row];
	//currentSelection = [tView indexPathForSelectedRow];
	[self hideDatePicker];
}
*/

/*
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
    [theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:NO];
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:newIndexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
		if(selected.count < 3){
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			[selected addObject:newIndexPath];
		}
        // Set model-object attribute associated with row
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        // Unset model-object attribute associated with row
		[selected removeObject:newIndexPath];
    }
}
*/

-(BOOL)allowTestVersion
{
	NSInteger count=[Score retrieveScoresCount:deleg.database];
	if(count < 3){
		return TRUE;
	}
	else{
		return FALSE;
	}
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0){
		//[[UIApplication sharedApplication] openURL: [NSURL URLWithString: kGolfMemoirURL]];
	[deleg.pay requestProductData:kGolfMemoirProductIdentifier];
	}
	else if(buttonIndex == 1){
		[deleg.pay requestProductData:kGolfMemoirGoldProductIdentifier];
			//[[UIApplication sharedApplication] openURL: [NSURL URLWithString: kGolfMemoirProductIdentifier]];
	}
	else if(buttonIndex == 2){
		UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[UnlockWebViewController alloc] init:kServiceUnlock]];
		[self presentViewController:dViewC animated:TRUE completion:nil];
		[dViewC release];
	}		
	else if(buttonIndex == 3){
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: kGolfMemoirURL]];
	}		
}

- (void)courseMainAction:(id)sender
{
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		[self gameDateAction:sender];
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 1){
		[self startGameAction:sender];
	}
}	

- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	/*CGRect pickerRect = CGRectMake(	0.0,
								   screenRect.size.height - kToolbarHeight - size.height,
								   size.width,
								   size.height);
	 */
	CGRect pickerRect = CGRectMake(	0.0,
								0.0,
								   screenRect.size.width,
								   screenRect.size.height-250);
	return pickerRect;
}

- (void)hideDatePicker
{
	if((datePickerView != nil) && (datePickerView.hidden==FALSE)){
	myDate=datePickerView.date;
	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	dateFormat.dateStyle = kCFDateFormatterShortStyle;
	NSString *dt = [dateFormat stringFromDate:myDate];
	[dateFormat release];
	self.navigationItem.leftBarButtonItem.title=dt;
	datePickerView.hidden=TRUE;
	}
}
- (void)gameDateAction:(id)sender
{
	/*
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[DatePickerController alloc] init]];
	[self presentModalViewController:dViewC animated:TRUE];
	[dViewC release];
	 */
	if(datePickerView==nil){
		datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
		datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		datePickerView.datePickerMode = UIDatePickerModeDate;
		
		// note we are using CGRectZero for the dimensions of our picker view,
		// this is because picker views have a built in optimum size,
		// you just need to set the correct origin in your view.
		//
		// position the picker at the bottom
		CGSize pickerSize = CGSizeMake(300, 500);
		datePickerView.frame = [self pickerFrameWithSize:pickerSize];

		[self.view addSubview:datePickerView];
		self.navigationItem.leftBarButtonItem.title=kDateEnterString;
	}
	else{
		
		if(datePickerView.hidden==FALSE){
			[self hideDatePicker];
		}
		else{
			datePickerView.hidden = FALSE;
			self.navigationItem.leftBarButtonItem.title=kDateEnterString;
		}
	}
}

- (void)startGameAction:(id)sender
{
	// the add button was clicked, handle it here
	//
#ifdef TEST_VERSION
	User *myUser=[[User alloc] initWithDB:deleg.database];
	
	if((myUser.service & kServiceUnlock) == 0){
		[myUser updateService];
		[myUser toDB];
		if((myUser.service & kServiceUnlock) == 0)
		if( ![self allowTestVersion]){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pay" message:@"Please click Regular button if you want to buy unlimited scores or click Premium button if you want to buy unlimited scores and photo upload. "
														   delegate:self cancelButtonTitle:@"Regular" otherButtonTitles:@"Premium", nil];
			[alert show];
			[alert release];
			return;
		}
	}
#endif
	
	[self hideDatePicker];
	NSInteger ind=currentSelection;
	if(ind != -1 ){
		int primaryKey = [Score retrieveOpenGameDatabase:deleg.database] ;
		if(primaryKey == -1){
			primaryKey= [Score insertNewScoreIntoDatabase:deleg.database];
			deleg.mScore = [[Score alloc] initWithPrimaryKey:primaryKey database:deleg.database];
		} 
        
		deleg.mScore.mCourse = [courseList objectAtIndex:ind];
		deleg.mScore.courseID=deleg.mScore.mCourse.primaryKey;
		deleg.mScore.playDate = myDate;
		deleg.mScore.teeType = myTeeType;
		deleg.mScore.gameType=myGameType;
		deleg.mScore.scoreType=myScoreType;
		if(myGameType == kBackNineEnum)
			deleg.mScore.holeNumber=10;
		else
			deleg.mScore.holeNumber=1;
		deleg.mScore.mCourse.holeNumber = deleg.mScore.holeNumber;
		
		[deleg.mScore toDB];
	
		if(holeController == nil)
			holeController = [[GameFriendsViewController alloc] init];	
		[(UINavigationController *)[self parentViewController] pushViewController:holeController animated:TRUE];
	  }
	else{
		// open a dialog with an OK and cancel button
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Please Pick A Course"
																 delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
	
}

- (void)addCourseButtonAction:(id)sender
{
	/*
	UIViewController *targetViewController = [[EditCourseController alloc] initWithCourse:nil];
	[[self navigationController] pushViewController:targetViewController animated:YES];
	 */
	deleg.tabBarController.selectedIndex=2;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.courseList = [Course retrieveAllCourses:deleg.database];
	[tView reloadData]; 
	//[tView selectRowAtIndexPath:currentSelection animated:YES scrollPosition:UITableViewScrollPositionNone];
	[self refreshView];
}

-(void)refreshView{
	
	if(deleg.mScore.mCourse !=nil){
		//update course
		NSInteger rowID=[courseList indexOfObject:deleg.mScore.mCourse];
		if(rowID >=0){
			NSIndexPath *tableSelection = [tView indexPathForSelectedRow];
			if(tableSelection != nil)
				[tView deselectRowAtIndexPath:tableSelection animated:NO];
			else{
				tableSelection = [NSIndexPath indexPathForRow:rowID inSection:0];
			}
			
			
			[tView selectRowAtIndexPath:tableSelection animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			[tView deselectRowAtIndexPath:tableSelection animated:YES];
			UITableViewCell *newCell = [tView cellForRowAtIndexPath:tableSelection];
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			currentSelection=tableSelection.row;
			
		}

		//update date
		myDate = deleg.mScore.playDate;
		NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
		dateFormat.dateStyle = kCFDateFormatterShortStyle;
		NSString *dt = [dateFormat stringFromDate:myDate];
		[dateFormat release];
		changeButton.title=dt;
		
		//update tee type
		myTeeType = deleg.mScore.teeType;
		if(myTeeType==kBlackTee){
			sView.selectedSegmentIndex=0;
		}
		else if(myTeeType==kBlueTee){
			sView.selectedSegmentIndex=1;
		}
		else if(myTeeType==kWhiteTee){
			sView.selectedSegmentIndex=2;
		}
		else if(myTeeType==kRedTee){
			sView.selectedSegmentIndex=3;
		}
		
		//update gametype
		myGameType = deleg.mScore.gameType;
		gView.selectedSegmentIndex = myGameType;
		
		//update scoretype
		myScoreType = deleg.mScore.scoreType;
		scoreTypeView.selectedSegmentIndex=myScoreType;
	}
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