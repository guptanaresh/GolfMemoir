//
//  GameHoleViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//  access: sr72014323

#import "EditLocationController.h"
#import "CourseMainViewController.h"
#import "GolfMemoirAppDelegate.h"
#import "Constants.h"
#import "ScoreCardTable.h"



@implementation EditLocationController

@synthesize deleg, mCourse, longView, latView, parView, parLabel, hcpView, hcpLabel;
@synthesize blackView;
@synthesize blueView;
@synthesize whiteView;
@synthesize redView, parControlView, hcpControlView, bannerVisible;


- (id)initWithCourse:(Course *)aCourse
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		// this will appear as the title in the navigation bar
			mCourse = aCourse;
		clm = [[CLLocationManager alloc] init];
		clm.delegate = self;
		formatter=[[NSNumberFormatter alloc] init];
		[formatter setMaximumFractionDigits:6];
		holeTypeArray = [NSArray arrayWithObjects: @"Straight",  @"Right Dogleg",  @"Left Dogleg", nil];
	}
	showIncompleteWarning = TRUE;
	return self;
}

- (void)dealloc
{
	if(adMobAd != nil)
	adMobAd.delegate=nil;

	[formatter release];
	[holeTypeArray release];
	[clm release];
	[super dealloc];
}


- (void)loadView
{
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	cView = [[[NSBundle mainBundle] loadNibNamed:@"EditLocation" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];

	adMobAd = (ADBannerView *)[cView viewWithTag:kADBannerViewLocation];
	if(adMobAd != nil){
		adMobAd.delegate=self;
		bannerVisible=TRUE;
	}
	
	longView = (UITextField *)[cView viewWithTag:kLongViewTag];
	longView.delegate = self;
	latView = (UITextField *)[cView viewWithTag:kLatViewTag];
	latView.delegate = self;
	
	UIButton *bView = (UIButton *)[cView viewWithTag:kTeeButtonTag];
	[bView addTarget:self action:@selector(setLocationAction:) forControlEvents:UIControlEventTouchUpInside];
	bView = (UIButton *)[cView viewWithTag:kPinButtonTag];
	[bView addTarget:self action:@selector(setLocationAction:) forControlEvents:UIControlEventTouchUpInside];
	bView = (UIButton *)[cView viewWithTag:kFrontPinButtonTag];
	[bView addTarget:self action:@selector(setLocationAction:) forControlEvents:UIControlEventTouchUpInside];
	// hidden for now
	bView.hidden=TRUE;
	bView = (UIButton *)[cView viewWithTag:kBackPinButtonTag];
	[bView addTarget:self action:@selector(setLocationAction:) forControlEvents:UIControlEventTouchUpInside];
	bView.hidden=TRUE;
	((UITextField *)[cView viewWithTag:kFrontPinLongViewTag]).hidden = TRUE;
	((UITextField *)[cView viewWithTag:kFrontPinLatViewTag]).hidden = TRUE;
	((UITextField *)[cView viewWithTag:kBackPinLongViewTag]).hidden = TRUE;
	((UITextField *)[cView viewWithTag:kBackPinLatViewTag]).hidden = TRUE;
	
	
	if([CLLocationManager locationServicesEnabled]){
		longView.enabled = FALSE;
		latView.enabled = FALSE;
	}
	
	
	/*
	parLabel = (UILabel *)[cView viewWithTag:kParLabelTag];
	 parView = (UISlider *)[cView viewWithTag:kParSliderTag];
	parView.value=mCourse.curHole.whitePar;
	[parView addTarget:self action:@selector(setParAction:) forControlEvents:UIControlEventValueChanged];
	 hcpLabel = (UILabel *)[cView viewWithTag:kHcpLabelTag];
	 hcpView = (UISlider *)[cView viewWithTag:kHcpSliderTag];
	 //[hcpView setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
	 hcpView.value=mCourse.curHole.hcp;
	 [hcpView addTarget:self action:@selector(setHcpAction:) forControlEvents:UIControlEventValueChanged];
	 */
	parControlView = (UISegmentedControl *)[cView viewWithTag:kParrControlViewTag];
	[parControlView addTarget:self action:@selector(parControlAction:) forControlEvents:UIControlEventValueChanged];
	[parControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:mCourse.curHole.whitePar]] forSegmentAtIndex:1];
	hcpControlView = (UISegmentedControl *)[cView viewWithTag:kHcpControlViewTag];
	[hcpControlView addTarget:self action:@selector(hcpControlAction:) forControlEvents:UIControlEventValueChanged];
	[hcpControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:mCourse.curHole.hcp]] forSegmentAtIndex:1];
	

	UITextView *yardView=(UITextView *)[cView viewWithTag:kYardTextViewTag];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL metersBool = [defaults boolForKey:MY_DISTANCE_PREF_KEY];
	if(metersBool){
		yardView.text = MY_DISTANCE_TEXT_METERS;
	}
	else{
		yardView.text = MY_DISTANCE_TEXT_YARDS;
	}
	blackView = (UITextField *)[cView viewWithTag:kBlackViewTag];
	blackView.delegate = self;
	blackView.textColor = [UIColor whiteColor];
	blueView = (UITextField *)[cView viewWithTag:kBlueViewTag];
	blueView.delegate = self;
	whiteView = (UITextField *)[cView viewWithTag:kWhiteViewTag];
	whiteView.delegate = self;
	redView = (UITextField *)[cView viewWithTag:kRedViewTag];
	redView.delegate = self;
	
	holeLayout = (UISegmentedControl *)[cView viewWithTag:kHoleLayout];
	[holeLayout addTarget:self action:@selector(changeHoleLayoutAction:) forControlEvents:UIControlEventValueChanged];
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];

	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: [UIImage imageNamed:@"left.png" ], 
								   [UIImage imageNamed:@"right.png"],
								   nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.backgroundColor=[UIColor clearColor];
	
	[segmentedControl addTarget:self action:@selector(changeHoleAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 120, kCustomButtonHeight);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
	[self.navigationItem.leftBarButtonItem initWithTitle:mCourse.courseName style:UIBarButtonItemStyleBordered target:self action:@selector(saveAction:)];
	
	[self makeViewTitle];
	[self refreshLocations];
	
}

- (void)saveAction:(id)sender
{
	/*
	mCourse.curHole.hcp = [hcpLabel.text intValue];
	mCourse.curHole.whitePar = [parLabel.text intValue];
	 */
	mCourse.curHole.blackYard=[blackView.text intValue];
	mCourse.curHole.blueYard=[blueView.text intValue];
	mCourse.curHole.whiteYard=[whiteView.text intValue];
	mCourse.curHole.orangeYard=[redView.text intValue];
	[mCourse.curHole toDB];
}


- (void)changeHoleLayoutAction:(id)sender
{
	[self resignKeyboard];
	mCourse.curHole.holeType=((UISegmentedControl *)sender).selectedSegmentIndex;
	[mCourse.curHole toDB];
	
}



- (void)changeHoleAction:(id)sender
{
	[self resignKeyboard];
	[self saveAction:sender];
	
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 1){
		[self changeHole:YES];
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		[self changeHole:NO];
	}
	
}
/*
- (void)setParAction:(id)sender
{
	[self resignKeyboard];
	UISlider *lSlider = ((UISlider *)sender);
	NSInteger newVal=lSlider.value;
	if(mCourse.curHole.whitePar != newVal){
		mCourse.curHole.whitePar=newVal;
		parLabel.text=[NSString stringWithFormat:@"%i",mCourse.curHole.whitePar];
		//[mCourse.curHole toDB];
	}
}

- (void)setHcpAction:(id)sender
{
	[self resignKeyboard];
	UISlider *lSlider = ((UISlider *)sender);
	NSInteger newVal=lSlider.value;
	if(mCourse.curHole.hcp != newVal){
		mCourse.curHole.hcp=lSlider.value;
		hcpLabel.text=[NSString stringWithFormat:@"%i",mCourse.curHole.hcp];
		//[mCourse.curHole toDB];
	}
}
*/
- (void)changeHole:(BOOL)up
{
	
	if(up == YES){
		if(mCourse.holeNumber <18){
			mCourse.holeNumber +=1;
		}
	}
	else{
		if(mCourse.holeNumber > 1){
			mCourse.holeNumber -=1;
		}
	}
	[mCourse toDB];
	
	[self makeViewTitle];
	[self refreshLocations];
	
}

-(void)makeViewTitle
{
	self.navigationItem.title=[@"Hole " stringByAppendingString:[formatter stringFromNumber:[NSNumber numberWithInteger:mCourse.holeNumber]]];
}	

- (void)parControlAction:(id)sender
{
	[self resignKeyboard];
	UISegmentedControl *csender = (UISegmentedControl *)sender;
	if(csender.selectedSegmentIndex == 2){
		mCourse.curHole.whitePar++;		
	}
	else if(csender.selectedSegmentIndex == 0){
		mCourse.curHole.whitePar--;		
		if(mCourse.curHole.whitePar < 0)
			mCourse.curHole.whitePar = 0;
	}
	[((UISegmentedControl *)sender) setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:mCourse.curHole.whitePar]] forSegmentAtIndex:1];
	[mCourse.curHole toDB];
}
- (void)hcpControlAction:(id)sender
{
	[self resignKeyboard];
	UISegmentedControl *csender = (UISegmentedControl *)sender;
	if(csender.selectedSegmentIndex == 2){
		mCourse.curHole.hcp++;		
	}
	else if(csender.selectedSegmentIndex == 0){
		mCourse.curHole.hcp--;
		if(mCourse.curHole.hcp < 0)
			mCourse.curHole.hcp = 0;
	}
	[((UISegmentedControl *)sender) setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:mCourse.curHole.hcp]] forSegmentAtIndex:1];
	[mCourse.curHole toDB];
}


-(void)refreshLocations
{
	/*
	 hcpLabel.text=[NSString stringWithFormat:@"%i",mCourse.curHole.hcp];
	hcpView.value=mCourse.curHole.hcp;
	parLabel.text=[NSString stringWithFormat:@"%i",mCourse.curHole.whitePar];
	parView.value=mCourse.curHole.whitePar;
	 */
	[parControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:mCourse.curHole.whitePar]] forSegmentAtIndex:1];
	[hcpControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:mCourse.curHole.hcp]] forSegmentAtIndex:1];
	blackView.text=[NSString stringWithFormat:@"%i",mCourse.curHole.blackYard];
	blueView.text=[NSString stringWithFormat:@"%i",mCourse.curHole.blueYard];
	whiteView.text=[NSString stringWithFormat:@"%i",mCourse.curHole.whiteYard];
	redView.text=[NSString stringWithFormat:@"%i",mCourse.curHole.orangeYard];
	holeLayout.selectedSegmentIndex = mCourse.curHole.holeType;
	if(mCourse.curHole.latitude != 0.0 || mCourse.curHole.longitude != 0.0){
		NSString *lStr = [formatter stringFromNumber:[NSNumber numberWithDouble:mCourse.curHole.longitude]];
		NSString *laStr = [formatter stringFromNumber:[NSNumber numberWithDouble:mCourse.curHole.latitude]];
		((UITextField *)[cView viewWithTag:kPinLongViewTag]).text = lStr;
		((UITextField *)[cView viewWithTag:kPinLatViewTag]).text = laStr;
	}
	else{
		((UITextField *)[cView viewWithTag:kPinLongViewTag]).text = @"";
		((UITextField *)[cView viewWithTag:kPinLatViewTag]).text = @"";
	}
	
	if(mCourse.curHole.teeLongitude != 0.0 || mCourse.curHole.teeLatitude != 0.0){
		NSString *lStr = [formatter stringFromNumber:[NSNumber numberWithDouble:mCourse.curHole.teeLongitude]];
		NSString *laStr = [formatter stringFromNumber:[NSNumber numberWithDouble:mCourse.curHole.teeLatitude]];
		((UITextField *)[cView viewWithTag:kTeeLongViewTag]).text = lStr;
		((UITextField *)[cView viewWithTag:kTeeLatViewTag]).text = laStr;
	}
	else{
		((UITextField *)[cView viewWithTag:kTeeLongViewTag]).text = @"";
		((UITextField *)[cView viewWithTag:kTeeLatViewTag]).text = @"";
	}
	if(mCourse.curHole.frontLongitude != 0.0 || mCourse.curHole.frontLatitude != 0.0){
		NSString *lStr = [formatter stringFromNumber:[NSNumber numberWithDouble:mCourse.curHole.frontLongitude]];
		NSString *laStr = [formatter stringFromNumber:[NSNumber numberWithDouble:mCourse.curHole.frontLatitude]];
		((UITextField *)[cView viewWithTag:kFrontPinLongViewTag]).text = lStr;
		((UITextField *)[cView viewWithTag:kFrontPinLatViewTag]).text = laStr;
	}
	else{
		((UITextField *)[cView viewWithTag:kFrontPinLongViewTag]).text = @"";
		((UITextField *)[cView viewWithTag:kFrontPinLatViewTag]).text = @"";
	}
	if(mCourse.curHole.backLongitude != 0.0 || mCourse.curHole.backLatitude != 0.0){
		NSString *lStr = [formatter stringFromNumber:[NSNumber numberWithDouble:mCourse.curHole.backLongitude]];
		NSString *laStr = [formatter stringFromNumber:[NSNumber numberWithDouble:mCourse.curHole.backLatitude]];
		((UITextField *)[cView viewWithTag:kBackPinLongViewTag]).text = lStr;
		((UITextField *)[cView viewWithTag:kBackPinLatViewTag]).text = laStr;
	}
	else{
		((UITextField *)[cView viewWithTag:kBackPinLongViewTag]).text = @"";
		((UITextField *)[cView viewWithTag:kBackPinLatViewTag]).text = @"";
	}
	
}	



-(void) resignKeyboard
{
	[longView resignFirstResponder];
	[latView resignFirstResponder];
	[blackView resignFirstResponder];
	[blueView resignFirstResponder];
	[whiteView resignFirstResponder];
	[redView resignFirstResponder];
	
}



- (void)setLocationAction:(id)sender
{
	[self resignKeyboard];
	CLLocation *newLocation = clm.location;
	UIButton *but=(UIButton *)sender;
	if(newLocation != nil && [CLLocationManager locationServicesEnabled]){
		if(but.tag == kTeeButtonTag){
			mCourse.curHole.teeLatitude = newLocation.coordinate.latitude;
			mCourse.curHole.teeLongitude = newLocation.coordinate.longitude;
		}
		else if(but.tag == kPinButtonTag){
			mCourse.curHole.latitude = newLocation.coordinate.latitude;
			mCourse.curHole.longitude = newLocation.coordinate.longitude;
		}
		else if(but.tag == kFrontPinButtonTag){
			mCourse.curHole.frontLatitude = newLocation.coordinate.latitude;
			mCourse.curHole.frontLongitude = newLocation.coordinate.longitude;
		}
		else if(but.tag == kBackPinButtonTag){
			mCourse.curHole.backLatitude = newLocation.coordinate.latitude;
			mCourse.curHole.backLongitude = newLocation.coordinate.longitude;
		}
	}

	[mCourse.curHole toDB];
	
	[self refreshLocations];
}



- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	if(newLocation !=nil){
	    if (!signbit(newLocation.horizontalAccuracy)) {
			longView.text = [formatter stringFromNumber:[NSNumber numberWithDouble:newLocation.coordinate.longitude]] ;
			latView.text = [formatter stringFromNumber:[NSNumber numberWithDouble:newLocation.coordinate.latitude]] ;
		}
	}
	
	
}

- (void)viewDidAppear:(BOOL)animated
{
	[clm startUpdatingLocation];
}
- (void)viewDidDisappear:(BOOL)animated
{
	[clm stopUpdatingLocation];
	
}
- (void)viewWillDisappear:(BOOL)animated
{
	if(showIncompleteWarning && ![mCourse worthWebUpload]){
		inCompleteAlert = [[UIAlertView alloc] initWithTitle:mCourse.courseName message:@"Please enter data for all the holes. Click on the left or right arrow on the navigation bar."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[inCompleteAlert show];
		[inCompleteAlert release];
	}
	[self saveAction:self];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField           // became first responder
{
	return TRUE;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
{
	return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
	if(textField == blackView){
		[blueView becomeFirstResponder];
	}
	else if(textField == blueView){
		[whiteView becomeFirstResponder];
	}
	else if(textField == whiteView){
		[redView becomeFirstResponder];
	}
	else
		[self resignKeyboard];
	return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField            // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
	
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


@end