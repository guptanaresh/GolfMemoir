//
//  GameHoleViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//  access: sr72014323

#import "EditCourseController.h"
#import <AddressBookUI/AddressBookUI.h>


@implementation EditCourseController

@synthesize deleg, mCourse, tView, nameView, cView;
@synthesize addressView;
@synthesize cityView;
@synthesize stateView;
@synthesize countryView;
@synthesize phoneView;
@synthesize urlView, zipView, bannerVisible;


- (id)initWithCourse:(Course *)aCourse
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		// this will appear as the title in the navigation bar
		if(aCourse == nil){
			NSInteger pk=[Course insertNewCourseIntoDatabase:deleg.database];
			mCourse = [[Course alloc] initWithPrimaryKey:pk database:deleg.database];
		}
		else{
			mCourse = aCourse;
		}
		clm = [[CLLocationManager alloc] init];
		clm.delegate = self;
		numPlacemark = 0;
	}
	
	showIncompleteWarning = TRUE;
	placemarkDict=nil;
	placemarkAlert=nil;
	return self;
}

- (void)dealloc
{
	
	adMobAd.delegate=nil;
	
	if(placemarkDict)
	[placemarkDict release];
	[super dealloc];
}


- (void)loadView
{
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
	cView = [[[NSBundle mainBundle] loadNibNamed:@"EditCourse" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];

	adMobAd = (ADBannerView *)[cView viewWithTag:kADBannerView];
	adMobAd.delegate=self;
	bannerVisible=TRUE;
	
	nameView = (UITextField *)[cView viewWithTag:kNameViewTag];
	addressView = (UITextField *)[cView viewWithTag:kAddressViewTag];
	addressView.delegate=self;
	cityView = (UITextField *)[cView viewWithTag:kCityViewTag];
	cityView.delegate=self;
	stateView = (UITextField *)[cView viewWithTag:kStateViewTag];
	stateView.delegate=self;
	countryView = (UITextField *)[cView viewWithTag:kCountryViewTag];
	countryView.delegate=self;
	phoneView = (UITextField *)[cView viewWithTag:kPhoneViewTag];
	phoneView.delegate=self;
	urlView = (UITextField *)[cView viewWithTag:kURLViewTag];
	urlView.delegate=self;
	zipView = (UITextField *)[cView viewWithTag:kZipViewTag];
	zipView.delegate=self;
	
	UITextField *tv1;
	tv1= (UITextField *)[cView viewWithTag:kBlackCourseRatingViewTag];
	tv1.delegate=self;
	if(mCourse.blackRate !=0)
		tv1.text=[NSString stringWithFormat:@"%3.2lf",mCourse.blackRate];
	tv1= (UITextField *)[cView viewWithTag:kBlueCourseRatingViewTag];
	tv1.delegate=self;
	if(mCourse.blueRate !=0)
		tv1.text=[NSString stringWithFormat:@"%3.2lf",mCourse.blueRate];
	tv1= (UITextField *)[cView viewWithTag:kWhiteCourseRatingViewTag];
	tv1.delegate=self;
	if(mCourse.whiteRate !=0)
		tv1.text=[NSString stringWithFormat:@"%3.2lf",mCourse.whiteRate];
	tv1= (UITextField *)[cView viewWithTag:kOrangeCourseRatingViewTag];
	tv1.delegate=self;
	if(mCourse.orangeRate !=0)
		tv1.text=[NSString stringWithFormat:@"%3.2lf",mCourse.orangeRate];

	tv1= (UITextField *)[cView viewWithTag:kBlackSlopeRatingViewTag];
	tv1.delegate=self;
	if(mCourse.blackSlope !=0)
		tv1.text=[NSString stringWithFormat:@"%i",mCourse.blackSlope];
	tv1= (UITextField *)[cView viewWithTag:kBlueSlopeRatingViewTag];
	tv1.delegate=self;
	if(mCourse.blueSlope !=0)
		tv1.text=[NSString stringWithFormat:@"%i",mCourse.blueSlope];
	tv1= (UITextField *)[cView viewWithTag:kWhiteSlopeRatingViewTag];
	tv1.delegate=self;
	if(mCourse.whiteSlope !=0)
		tv1.text=[NSString stringWithFormat:@"%i",mCourse.whiteSlope];
	tv1= (UITextField *)[cView viewWithTag:kOrangeSlopeRatingViewTag];
	tv1.delegate=self;
	if(mCourse.orangeSlope !=0)
		tv1.text=[NSString stringWithFormat:@"%i",mCourse.orangeSlope];
	
	
	addressView.text=mCourse.courseAddress;
	cityView.text=mCourse.courseCity;
	stateView.text=mCourse.courseState;
	countryView.text=mCourse.courseCountry;
	phoneView.text=mCourse.coursePhone;
	urlView.text=mCourse.courseWebsite;
	zipView.text=mCourse.courseZipcode;

	if([self courseNameValidate:mCourse.courseName]){
		nameView.text=mCourse.courseName;
		self.title = mCourse.courseName;
	}
	nameView.delegate=self;
	[nameView addTarget:self action:@selector(nameTextChanged:) forControlEvents:UIControlEventEditingChanged];
	
	UIButton *but1=(UIButton *)[cView viewWithTag:kURLButtonTag];
	[but1 addTarget:self action:@selector(launchWebsiteAction:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *but2=(UIButton *)[cView viewWithTag:kPhoneButtonTag];
	[but2 addTarget:self action:@selector(launchPhoneAction:) forControlEvents:UIControlEventTouchUpInside];
	UILabel *phoneLabel=(UILabel *)[cView viewWithTag:kPhoneLabelTag];
	
	if([[[UIDevice currentDevice] model] hasPrefix:@"iPod"])
		but2.hidden=TRUE;
	else
		phoneLabel.hidden=TRUE;
	tView = (UITableView *)[cView viewWithTag:kHoleTableTag];
	tView.delegate=self;
	tView.dataSource=self;

	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(preSaveAction:)];


	NSArray *segmentTextContent = [NSArray arrayWithObjects: @"Backup", @"Delete", nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.backgroundColor=[UIColor clearColor];
	
	[segmentedControl addTarget:self action:@selector(rightBarAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 120, kCustomButtonHeight);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
	
/*	
	UIBarButtonItem *delButton = [[UIBarButtonItem alloc]
								  initWithTitle:NSLocalizedString(@"Delete", @"") style:UIBarButtonItemStyleBordered
								  target:self action:@selector(deleteAction:)];
	self.navigationItem.rightBarButtonItem = delButton;
	[delButton release];
 */
	
	

}

- (void)deleteAction:(id)sender
{
	BOOL val = [mCourse deleteFromDatabase];
	if(val == FALSE){
		// open a dialog with an OK and cancel button
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Can't delete this course because it's in use."
																 delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
	else{
		[[self navigationController] popViewControllerAnimated:YES];
	}

}

- (void)upload:(id)sender
{
		[mCourse upload];
}



- (void)rightBarAction:(id)sender
{
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		if([mCourse worthWebUpload]){
			if([self courseNameValidate:mCourse.courseName])
				[self upload:sender];
			else{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:mCourse.courseName message:@"Please Enter A Valid Course Name."
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
				[alert release];
			}
		}
		else{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:mCourse.courseName message:@"Please make sure all the data is entered for this course."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];
		}
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 1){
		showIncompleteWarning = FALSE;
		[self deleteAction:sender];
	}
	
	
}

-(BOOL)courseNameValidate:(NSString *)name
{
	if(name.length >0 && [name maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding] >0 && 
	   (![name isEqualToString:NSLocalizedString(@"Enter Name of A Course", @"")])){
		return TRUE;
	}
	return FALSE;
}

-(void)saveAllEditableFields
{
	mCourse.courseAddress=addressView.text;
	mCourse.courseCity=cityView.text;
	mCourse.courseState=stateView.text;
	mCourse.courseCountry=countryView.text;
	mCourse.coursePhone=phoneView.text;
	mCourse.courseWebsite=urlView.text;
	mCourse.courseZipcode=zipView.text;
	UITextField *tv1;
	tv1= (UITextField *)[cView viewWithTag:kBlackCourseRatingViewTag];
	mCourse.blackRate=[tv1.text doubleValue];
	tv1= (UITextField *)[cView viewWithTag:kBlueCourseRatingViewTag];
	mCourse.blueRate=[tv1.text doubleValue];
	tv1= (UITextField *)[cView viewWithTag:kWhiteCourseRatingViewTag];
	mCourse.whiteRate=[tv1.text doubleValue];
	tv1= (UITextField *)[cView viewWithTag:kOrangeCourseRatingViewTag];
	mCourse.orangeRate=[tv1.text doubleValue];

	tv1= (UITextField *)[cView viewWithTag:kBlackSlopeRatingViewTag];
	mCourse.blackSlope=[tv1.text intValue];
	tv1= (UITextField *)[cView viewWithTag:kBlueSlopeRatingViewTag];
	mCourse.blueSlope=[tv1.text intValue];
	tv1= (UITextField *)[cView viewWithTag:kWhiteSlopeRatingViewTag];
	mCourse.whiteSlope=[tv1.text intValue];
	tv1= (UITextField *)[cView viewWithTag:kOrangeSlopeRatingViewTag];
	mCourse.orangeSlope=[tv1.text intValue];
	[mCourse toDB];

}
- (void)launchWebsiteAction:(id)sender
{
	[self saveAllEditableFields];
	NSString *url=nil;
	if([mCourse.courseWebsite hasPrefix:@"http"]){
		url = mCourse.courseWebsite;
	}
	else{
		url = [NSString stringWithFormat: @"http://%@", mCourse.courseWebsite];
	}
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (void)nameTextChanged:(id)sender
{
	UITextField *txView= (UITextField *)sender;
	NSString *str=txView.text; 
	if([str rangeOfString:@" "].length > 0)
		NSLog(@"%@", txView.text);
}


- (void)launchPhoneAction:(id)sender
{
	[self saveAllEditableFields];
	NSString *url = [NSString stringWithFormat: @"tel:%@", mCourse.coursePhone];
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}


- (void)preSaveAction:(id)sender
{
	mCourse.courseName = nameView.text;
	self.title = mCourse.courseName;
	if([self courseNameValidate:mCourse.courseName]){
		[self saveAllEditableFields];
		if([mCourse worthWebUpload]){
			backupActionSheet = [[UIActionSheet alloc] initWithTitle:@"Backup Course to GolfMemoir.com"
																	 delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
			backupActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
			[backupActionSheet showInView:self.view];
			[backupActionSheet release];
		}
		else{
			[[self navigationController] popViewControllerAnimated:YES];
		}
		
	}
	else{
		// open a dialog with an OK and cancel button
		validateActionSheet = [[UIActionSheet alloc] initWithTitle:@"Please Enter A Valid Course Name"
																 delegate:self cancelButtonTitle:@"Delete" destructiveButtonTitle:@"OK" otherButtonTitles:nil];
		validateActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		[validateActionSheet showInView:self.view];
		[validateActionSheet release];
	}
	
}

//@protocol UIActionSheetDelegate <NSObject>
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(actionSheet == backupActionSheet){
		if(buttonIndex == 0){
			[mCourse upload];
		}
		[[self navigationController] popViewControllerAnimated:YES];
	}
	else if(actionSheet == validateActionSheet){
			if(buttonIndex == 1){
				[mCourse deleteFromDatabase];
				[[self navigationController] popViewControllerAnimated:YES];
			}
	}
	else{
		[[self navigationController] popViewControllerAnimated:YES];
	}
}



-(void) resignKeyboard
{
	[nameView resignFirstResponder];
	[addressView resignFirstResponder];
	[cityView resignFirstResponder];
	[stateView resignFirstResponder];
	[countryView resignFirstResponder];
	[phoneView resignFirstResponder];
	[urlView resignFirstResponder];
	[zipView resignFirstResponder];
}


- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return 18;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section    // fixed font style. use custom view (UILabel) if you want something different
{
	return [NSString stringWithFormat:@"Hole%@Par%@Handicap", k5Spaces, k5Spaces];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row=indexPath.row+1;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%i", row]];
	mCourse.holeNumber = row;
	NSMutableString *aNameStr = [NSMutableString alloc];
	aNameStr = [NSString stringWithFormat:@"%@%i%@%i%@%i",k5Spaces, row, k10Spaces, mCourse.curHole.whitePar, k10Spaces, mCourse.curHole.hcp];
	
	if (cell != nil) {
		UILabel *alabel=(UILabel *)[cell.contentView viewWithTag:row];
		alabel.text=aNameStr;
	}
	else{
		
		CGRect rect;
		rect = CGRectMake(0.0, 0.0, 320.0, EDIT_ROW_HEIGHT);
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%i", row]] autorelease];
		/*		
		 UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"CourseCell" owner:self options:nil] lastObject ];
		 [cell.contentView addSubview:cView];
		 */
		
		/*
		 Create labels for the text fields; set the highlight color so that when the cell is selected it changes appropriately.
		 */
		UILabel *label;
		
		rect = CGRectMake(LEFT_COLUMN_OFFSET, (EDIT_ROW_HEIGHT - EDIT_LABEL_HEIGHT) / 2.0, LEFT_COLUMN_WIDTH+MIDDLE_COLUMN_WIDTH+RIGHT_COLUMN_WIDTH, EDIT_LABEL_HEIGHT);
		label = [[UILabel alloc] initWithFrame:rect];
		label.tag = row;
		label.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
		label.adjustsFontSizeToFitWidth = YES;
		label.text=aNameStr;
		[cell.contentView addSubview:label];
		label.highlightedTextColor = [UIColor whiteColor];
		[label release];
		
		
		rect= CGRectMake(FOURTH_COLUMN_OFFSET, (cell.frame.size.height -  EDIT_ROW_HEIGHT) / 2.0, FOURTH_COLUMN_WIDTH, EDIT_ROW_HEIGHT);
		
		UIButton *roundedButtonType = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		roundedButtonType.frame = rect;
		[roundedButtonType setTitle:@"Edit" forState:UIControlStateNormal];
		roundedButtonType.enabled=FALSE;
		//roundedButtonType.backgroundColor = [UIColor clearColor];
		[roundedButtonType addTarget:self action:@selector(setLocationAction:) forControlEvents:UIControlEventAllTouchEvents];
		
		[cell.contentView addSubview:roundedButtonType];
		[roundedButtonType release];
	}
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
		[self resignKeyboard];
		showIncompleteWarning=FALSE;
		mCourse.holeNumber = indexPath.row+1;
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		UIViewController *targetViewController = [[EditLocationController alloc] initWithCourse:mCourse];
		[[self navigationController] pushViewController:targetViewController animated:YES];
}


- (void)setLocationAction:(id)sender
{
	[self resignKeyboard];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}



- (void)textFieldDidEndEditing:(UITextField *)textField            // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
	if(textField == nameView){
	mCourse.courseName = textField.text;
	self.title = mCourse.courseName;
	if([textField isFirstResponder])
		[textField resignFirstResponder];
	}
	
}
- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{
		
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
{
	return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
	[textField resignFirstResponder];
	return TRUE;
}

- (void)viewDidAppear:(BOOL)animated
{
	[clm startUpdatingLocation];
}
- (void)viewDidDisappear:(BOOL)animated
{
	[clm stopUpdatingLocation];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[tView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(showIncompleteWarning && ![mCourse worthWebUpload]){
		inCompleteAlert = [[UIAlertView alloc] initWithTitle:mCourse.courseName message:@"Please make sure all the data is entered for this course."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[inCompleteAlert show];
		[inCompleteAlert release];
	}
	
}


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	//if(newLocation !=nil && oldLocation !=nil){
	if(!signbit(newLocation.horizontalAccuracy) )
	{
		numPlacemark++;
	    if ( numPlacemark == 2) {
			MKReverseGeocoder *geo= [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
			geo.delegate=self;
			[clm stopUpdatingLocation];
			[geo start];
		}
	}
	
	
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	NSLog(@"got placemark");
	placemarkDict=[[placemark addressDictionary] retain];
	NSString *locDesc=ABCreateStringWithAddressDictionary(placemarkDict, false);
	NSLog(@"%@", locDesc);
	/*
	locDesc=@"All Keys";
	for (id key in placemarkDict) {
		NSLog(@"key: %@, value: %@", key, [placemarkDict objectForKey:key]);
		locDesc = [NSString stringWithFormat:@"%@; key: %@, value: %@", locDesc, key, [placemarkDict objectForKey:key]];
	}
	 */
	placemarkAlert = [[UIAlertView alloc] initWithTitle:@"Found Address" message:locDesc
												   delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Accept", nil];
	[placemarkAlert show];
	[placemarkAlert release];
	
	[geocoder cancel];
}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	NSLog(@"goterror placemark");
	[geocoder cancel];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView == placemarkAlert){
		if(buttonIndex == 1){
			if(placemarkDict){
				addressView.text=[NSString stringWithFormat:@"%@ %@", (NSString *)[placemarkDict objectForKey:@"SubThoroughfare"], [placemarkDict objectForKey:(NSString *)kABPersonAddressStreetKey]];
				cityView.text=[placemarkDict objectForKey:(NSString *)kABPersonAddressCityKey];
				stateView.text=[placemarkDict objectForKey:(NSString *)kABPersonAddressStateKey];
				countryView.text=[placemarkDict objectForKey:(NSString *)kABPersonAddressCountryKey];
				zipView.text=[placemarkDict objectForKey:(NSString *)kABPersonAddressZIPKey];
			}

		}
	}
}

#pragma mark -
#pragma mark ADBannerViewDelegate methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	
    if (!self.bannerVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        //banner.hidden = NO;
		// assumes the banner view is offset 50 pixels so that it is not visible.
        banner.frame = CGRectOffset(banner.frame, 0, 50);
		bannerVisible=TRUE;
        [UIView commitAnimations];
    }
}
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	if (self.bannerVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -50);
		//banner.hidden = TRUE;
		self.bannerVisible=FALSE;
        [UIView commitAnimations];
    }
}

/*
- (NSString *)publisherId {
	return kAdID1; // this should be prefilled; if not, get it from www.admob.com
}

- (BOOL)useTestAd{
	return FALSE;
}

- (BOOL)mayAskForLocation {
	return NO; // this should be prefilled; if not, see AdMobProtocolDelegate.h for instructions
}

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView {
	NSLog(@"AdMob: Did receive ad");
	autoslider = [NSTimer scheduledTimerWithTimeInterval:AD_REFRESH_PERIOD target:self selector:@selector(refreshAd:) userInfo:nil repeats:YES];
}

// Request a new ad. If a new ad is successfully loaded, it will be animated into location.
- (void)refreshAd:(NSTimer *)timer {
	[adMobAd requestFreshAd];
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
	NSLog(@"AdMob: Did fail to receive ad");
	[adMobAd release];
	adMobAd = nil;
	// we could start a new ad request here, but in the interests of the user's battery life, let's not
}

*/


@end