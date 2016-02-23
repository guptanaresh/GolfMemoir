//
//  GameHoleViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//  access: sr72014323

#import "GameHoleViewController.h"
#import "LoginViewController.h"
#import "ScoreWebViewController.h"
#import "HolePickerView.h"
#import "GolfMemoirAppDelegate.h"
#include "UnlockWebViewController.h"
#import "Constants.h"
#import "ScoreCardTable.h"
#import "PayObserver.h"
#import "MapLocationViewController.h"



@implementation GameHoleViewController

@synthesize deleg, myScoreControlView, cView, cameraView, myScoreDistanceView, myScoreDistanceYard, myScoreDistanceButton, segmentedControl, myScoreTotalView;
@synthesize myPuttControlView, player2ControlView, player2TotalView, player3ControlView, player3TotalView, player4ControlView, player4TotalView;
@synthesize panel2View;
@synthesize panel3View;
@synthesize panel4View, metersBool, helpText, bannerVisible;


- (id)init
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		int primaryKey = [Score retrieveOpenGameDatabase:deleg.database] ;
		if(primaryKey != -1){
			if(deleg.mScore !=nil)
				[deleg.mScore release];
			deleg.mScore = [[Score alloc] initWithPrimaryKey:primaryKey database:deleg.database];
			[deleg.mScore.curHole readStroke];
		}
		clm = [[CLLocationManager alloc] init];
		clm.delegate = self;
		}
	formatter=[[NSNumberFormatter alloc] init];
	return self;
}

- (void)dealloc
{
	ADBannerView *banner = (ADBannerView *)[cView viewWithTag:kADBannerView];
	banner.delegate=nil;
	[formatter release];
	[clm release];
	[super dealloc];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
{
	if( interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
		return TRUE;
	else
		return FALSE;
}

- (void)loadView
{
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
	cView = [[[NSBundle mainBundle] loadNibNamed:@"HoleView" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];

	helpText = (UILabel *)[cView viewWithTag:kHelpTextTag];
	helpText.font = [UIFont italicSystemFontOfSize:12];

	ADBannerView *banner = (ADBannerView *)[cView viewWithTag:kADBannerView];
	banner.delegate=self;
	bannerVisible=TRUE;
	
	//cameraView = (UIButton *)[cView viewWithTag:kPhotoViewTag];
	//[cameraView addTarget:self action:@selector(photoaction:) forControlEvents:UIControlEventTouchUpInside];
		
	// My Score
	myScoreDistanceView = (UITextField *)[cView viewWithTag:kMyScoreDistanceViewTag];
	myScoreDistanceView.delegate=self;
	myScoreDistanceYard = (UILabel *)[cView viewWithTag:kMyScoreDistanceYardTag];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    metersBool = [defaults boolForKey:MY_DISTANCE_PREF_KEY];
	if(metersBool){
		myScoreDistanceYard.text = MY_DISTANCE_PREF_MT;
	}
	else{
		myScoreDistanceYard.text = MY_DISTANCE_PREF_YD;
	}
	myScoreDistanceButton = (UIButton *)[cView viewWithTag:kPinLocationButtonTag];
	[myScoreDistanceButton addTarget:self action:@selector(locationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	
	myPuttControlView = (UISegmentedControl *)[cView viewWithTag:kMyScorePuttOrDriveViewTag];
	myPuttControlView.selectedSegmentIndex = deleg.mScore.curHole.putt;
	[myPuttControlView addTarget:self action:@selector(myPuttControlAction:) forControlEvents:UIControlEventValueChanged];
	myScoreControlView = (UISegmentedControl *)[cView viewWithTag:kMyScoreControlViewTag];
	[myScoreControlView addTarget:self action:@selector(myScoreControlAction:) forControlEvents:UIControlEventValueChanged];
	[myScoreControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum]] forSegmentAtIndex:1];
	myScoreTotalView = (UILabel *)[cView viewWithTag:kMyScoreTotalViewTag];
	myScoreTotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:1]]];
	
	if([deleg.mScore hasPlayer2]){
		panel2View = [cView viewWithTag:kPlayer2ScoreViewTag];
		panel2View.hidden = FALSE;
		UILabel *player2LabelView = (UILabel *)[cView viewWithTag:kPlayer2LabelViewTag];
		player2LabelView.text = [deleg.mScore.player2Name stringByAppendingString:@":"];
		player2ControlView = (UISegmentedControl *)[cView viewWithTag:kPlayer2ControlViewTag];
		[player2ControlView addTarget:self action:@selector(player2ControlAction:) forControlEvents:UIControlEventValueChanged];
		[player2ControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum2]] forSegmentAtIndex:1];
		player2TotalView = (UILabel *)[cView viewWithTag:kPlayer2TotalViewTag];
		player2TotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:2]]];
	}
	
	if([deleg.mScore hasPlayer3]){
		panel3View = [cView viewWithTag:kPlayer3ScoreViewTag];
		panel3View.hidden = FALSE;
		UILabel *player2LabelView = (UILabel *)[cView viewWithTag:kPlayer3LabelViewTag];
		player2LabelView.text = [deleg.mScore.player3Name stringByAppendingString:@":"];
		player3ControlView = (UISegmentedControl *)[cView viewWithTag:kPlayer3ControlViewTag];
		[player3ControlView addTarget:self action:@selector(player3ControlAction:) forControlEvents:UIControlEventValueChanged];
		[player3ControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum3]] forSegmentAtIndex:1];
		player3TotalView = (UILabel *)[cView viewWithTag:kPlayer3TotalViewTag];
		player3TotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:3]]];
		
	}

	if([deleg.mScore hasPlayer4]){
		panel4View = [cView viewWithTag:kPlayer4ScoreViewTag];
		panel4View.hidden = FALSE;
		UILabel *player2LabelView = (UILabel *)[cView viewWithTag:kPlayer4LabelViewTag];
		player2LabelView.text = [deleg.mScore.player4Name stringByAppendingString:@":"];
		player4ControlView = (UISegmentedControl *)[cView viewWithTag:kPlayer4ControlViewTag];
		[player4ControlView addTarget:self action:@selector(player4ControlAction:) forControlEvents:UIControlEventValueChanged];
		[player4ControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum4]] forSegmentAtIndex:1];
		player4TotalView = (UILabel *)[cView viewWithTag:kPlayer4TotalViewTag];
		player4TotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:4]]];
		
	}
	

	//Stroke
	//NSArray *segmentTextContent = [NSArray arrayWithObjects: @"Prev Hole", @"Next Hole", @"Prev Stroke", @"Next Stroke", nil];
	//NSArray *segmentTextContent = [NSArray arrayWithObjects: @"Next Hole", @"Next Stroke",@"Photo", nil];
	NSArray *segmentTextContent = [NSArray arrayWithObjects: [UIImage imageNamed:@"left.png" ], 
															[UIImage imageNamed:@"right.png"],
															nil];
	segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.backgroundColor=[UIColor clearColor];

	[segmentedControl addTarget:self action:@selector(changeHoleAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 120, kCustomButtonHeight);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
	self.navigationItem.hidesBackButton=TRUE;

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(photoaction:)];

	// add it as the parent/content view to this UIViewController
	//self.cView = contentView;

	
	[self makeViewTitle];
	
	
	[segmentBarItem release];
	[segmentedControl release];
	[contentView release];
}

/*
- (void)viewDidLoad{
	NSString *imageStr = [deleg.mScore photoString:TRUE];
	UIImage *bkImage = [UIImage imageWithContentsOfFile:imageStr];
	if(bkImage==nil){
		bkImage = [UIImage imageNamed:@"bg1.png"];
	}
	[cameraView setBackgroundImage:bkImage forState:UIControlStateNormal];
}
*/

-(void) resignKeyboard
{
//	if([myScoreDistanceView isFirstResponder])
		[myScoreDistanceView resignFirstResponder];
}
-(void)makeViewTitle
{
	// this will appear as the title in the navigation bar
	CGRect tRect = CGRectMake(0, 0, 100, kCustomButtonHeight);
	UIView *tiView=[[UIView alloc] initWithFrame:tRect];
	tiView.opaque = FALSE;
	tiView.backgroundColor = [UIColor clearColor];

	NSString *str= [NSString stringWithFormat:@"Hole %d", deleg.mScore.holeNumber];
	UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, kCustomButtonHeight/2+10)];
	tLabel.opaque = FALSE;
	tLabel.text = str;
	tLabel.backgroundColor = [UIColor clearColor];
	tLabel.font = [UIFont boldSystemFontOfSize:16];
	tLabel.textColor=[UIColor whiteColor];
	tLabel.adjustsFontSizeToFitWidth = NO;
	NSInteger dist;
	if(deleg.mScore.teeType == kBlackTee)
		dist = deleg.mScore.mCourse.curHole.blackYard;
	else if(deleg.mScore.teeType == kBlueTee)
		dist = deleg.mScore.mCourse.curHole.blueYard;
	else if(deleg.mScore.teeType == kWhiteTee)
		dist = deleg.mScore.mCourse.curHole.whiteYard;
	else if(deleg.mScore.teeType == kRedTee)
		dist = deleg.mScore.mCourse.curHole.orangeYard;
	
	NSString *str2;
	if(metersBool){
		str2 = [NSString stringWithFormat:@"Par %d %@ %d", deleg.mScore.mCourse.curHole.whitePar, MY_DISTANCE_PREF_MT, dist];
	}
	else{
		str2 = [NSString stringWithFormat:@"Par %d %@ %d", deleg.mScore.mCourse.curHole.whitePar, MY_DISTANCE_PREF_YD, dist];
	}
	UILabel *bLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (kCustomButtonHeight/2+10), 100, kCustomButtonHeight/2-10)];
	bLabel.opaque = FALSE;
	bLabel.text = str2;
	bLabel.adjustsFontSizeToFitWidth = NO;
	bLabel.backgroundColor = [UIColor clearColor];
	bLabel.font = [UIFont boldSystemFontOfSize:14];
	bLabel.textColor=[UIColor whiteColor];
	[tiView addSubview:tLabel];
	[tiView addSubview:bLabel];
	self.navigationItem.titleView=tiView;
}	

- (void)locationButtonAction:(id)sender
{
	/*
	if(deleg.mScore.mCourse.curHole.longitude == 0.0 && deleg.mScore.mCourse.curHole.latitude == 0.0){
		// open a dialog with an OK and cancel button
		locationAlertView = [[UIAlertView alloc] initWithTitle:@"Hole Location Not Available" message:@"Please set location for this hole in the Courses tab."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[locationAlertView show];
		[locationAlertView release];
	}
	else{
		[self updateDistance:TRUE];
	}
	*/
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[MapLocationViewController alloc] init]];
	[self presentViewController:dViewC animated:TRUE completion:nil];
	[dViewC release];
}


- (void)photoaction:(id)sender
{
	[self resignKeyboard];
		UIImagePickerController *cam= [[UIImagePickerController alloc] init];
		if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES){
			cam.sourceType=UIImagePickerControllerSourceTypeCamera;
		}
		else{
			cam.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
		}
		cam.delegate=(id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> )self;
		[self presentViewController:cam animated:TRUE completion:nil];
	[cam release];
}

//
- (void)changeHoleAction:(id)sender
{
	[self resignKeyboard];
	
	if(((UISegmentedControl *)sender).selectedSegmentIndex == kSegmentNextHole){
		[self changeHole:YES];
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == kSegmentPrevHole){
		[self changeHole:NO];
	}

	/*
	NSString *imageStr = [deleg.mScore photoString:TRUE];
	UIImage *bkImage = [UIImage imageWithContentsOfFile:imageStr];
	if(bkImage==nil){
		bkImage = [UIImage imageNamed:@"bg1.png"];
	}
	[cameraView setBackgroundImage:bkImage forState:UIControlStateNormal];
	 */
	if([deleg.mScore.curHole readStroke]){
		myPuttControlView.selectedSegmentIndex = deleg.mScore.curHole.putt;
	}
	else{
		myPuttControlView.selectedSegmentIndex = kDriveEnum;
	}

	[myScoreControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum]] forSegmentAtIndex:1];
	myScoreTotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:1]]];

	[self updateDistance:FALSE];
	
	if([deleg.mScore hasPlayer2]){
		[player2ControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum2]] forSegmentAtIndex:1];
		player2TotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:2]]];
	}
	
	if([deleg.mScore hasPlayer3]){
		[player3ControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum3]] forSegmentAtIndex:1];
		player3TotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:3]]];
		
	}
	
	if([deleg.mScore hasPlayer4]){
		[player4ControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum4]] forSegmentAtIndex:1];
		player4TotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:4]]];
		
	}
	
//	[self.tView reloadData];
	
}



- (void)myScoreControlAction:(id)sender
{
	[self resignKeyboard];
	UISegmentedControl *csender = (UISegmentedControl *)sender;
	if(csender.selectedSegmentIndex == 2){
		deleg.mScore.curHole.strokeNum  = [[formatter numberFromString:[csender titleForSegmentAtIndex:1]] integerValue];
		deleg.mScore.curHole.strokeNum +=1;
		deleg.mScore.curHole.putt = myPuttControlView.selectedSegmentIndex;
		CLLocation *newLoc = clm.location;
		if(newLoc !=nil){
			deleg.mScore.curHole.longitude = newLoc.coordinate.longitude;
			deleg.mScore.curHole.latitude = newLoc.coordinate.latitude;
			deleg.mScore.curHole.distance = [NSNumber numberWithDouble:[self getDistance:newLoc]].integerValue;
					
		}
		[deleg.mScore.curHole toDB];
		[deleg.mScore.curHole saveStroke];

		[((UISegmentedControl *)sender) setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum]] forSegmentAtIndex:1];
		myScoreTotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:1]]];

		// look ahead for next stroke
		deleg.mScore.curHole.strokeNum +=1;
		if([deleg.mScore.curHole readStroke]){
			myPuttControlView.selectedSegmentIndex = deleg.mScore.curHole.putt;
		}
		//restore stroke data
		deleg.mScore.curHole.strokeNum -=1;

			
	}
	else if(csender.selectedSegmentIndex == 0){
		deleg.mScore.curHole.strokeNum  = [[formatter numberFromString:[csender titleForSegmentAtIndex:1]] integerValue];
		if(deleg.mScore.curHole.strokeNum > 0){
			[deleg.mScore.curHole readStroke];
			myPuttControlView.selectedSegmentIndex = deleg.mScore.curHole.putt;
		}
		
		deleg.mScore.curHole.strokeNum -=1;
		if(deleg.mScore.curHole.strokeNum < 0)
			deleg.mScore.curHole.strokeNum = 0;
		[deleg.mScore.curHole toDB];
		
		[((UISegmentedControl *)sender) setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum]] forSegmentAtIndex:1];
		myScoreTotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:1]]];
	}
	[self updateDistance:FALSE];

}
- (void)myPuttControlAction:(id)sender
{
	[self resignKeyboard];
	UISegmentedControl *csender = (UISegmentedControl *)sender;
	deleg.mScore.curHole.putt = csender.selectedSegmentIndex;	
}

- (void)player2ControlAction:(id)sender
{
	[self playerControlAction:sender playerNo:2];
}
- (void)player3ControlAction:(id)sender
{
	[self playerControlAction:sender playerNo:3];
}
- (void)player4ControlAction:(id)sender
{
	[self playerControlAction:sender playerNo:4];
}


- (void)playerControlAction:(id)sender  playerNo:(NSInteger) which
{
	[self resignKeyboard];
	UISegmentedControl *csender = (UISegmentedControl *)sender;
	if(which==2){
			deleg.mScore.curHole.strokeNum2  = [[formatter numberFromString:[csender titleForSegmentAtIndex:1]] integerValue];
			if(csender.selectedSegmentIndex == 2){
			deleg.mScore.curHole.strokeNum2 +=1;
			}
			else if(csender.selectedSegmentIndex == 0){
				deleg.mScore.curHole.strokeNum2 -=1;
				if(deleg.mScore.curHole.strokeNum2 < 1)
					deleg.mScore.curHole.strokeNum2 = 1;
			}
		[deleg.mScore.curHole toDB];

		[((UISegmentedControl *)sender) setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum2]] forSegmentAtIndex:1];
			player2TotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:2]]];
	}
	else if(which==3){
			deleg.mScore.curHole.strokeNum3  = [[formatter numberFromString:[csender titleForSegmentAtIndex:1]] integerValue];
			if(csender.selectedSegmentIndex == 2){
				deleg.mScore.curHole.strokeNum3 +=1;
			}
			else if(csender.selectedSegmentIndex == 0){
				deleg.mScore.curHole.strokeNum3 -=1;
				if(deleg.mScore.curHole.strokeNum3 < 1)
					deleg.mScore.curHole.strokeNum3 = 1;
			}
		[deleg.mScore.curHole toDB];

		[((UISegmentedControl *)sender) setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum3]] forSegmentAtIndex:1];
				player3TotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:3]]];
	}
	else if(which==4){
			deleg.mScore.curHole.strokeNum4  = [[formatter numberFromString:[csender titleForSegmentAtIndex:1]] integerValue];
			if(csender.selectedSegmentIndex == 2){
				deleg.mScore.curHole.strokeNum4 +=1;
			}
			else if(csender.selectedSegmentIndex == 0){
				deleg.mScore.curHole.strokeNum4 -=1;
				if(deleg.mScore.curHole.strokeNum4 < 1)
					deleg.mScore.curHole.strokeNum4 = 1;
			}
		[deleg.mScore.curHole toDB];

		[((UISegmentedControl *)sender) setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum4]] forSegmentAtIndex:1];
				player4TotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:4]]];
	}
		
	
}


- (void)changeHole:(BOOL)up
{
	deleg.mScore.curHole.strokeNum  = [[formatter numberFromString:[myScoreControlView titleForSegmentAtIndex:1]] integerValue];

	if(up == YES){
		[deleg.mScore toDB];
		if(((deleg.mScore.gameType==kFrontNineEnum) && (deleg.mScore.holeNumber <9)) || ((deleg.mScore.gameType!=kFrontNineEnum) && (deleg.mScore.holeNumber <18))){
			deleg.mScore.holeNumber +=1;
			//[segmentedControl setEnabled:YES forSegmentAtIndex: kSegmentPrevHole];
			//[segmentedControl setEnabled:YES forSegmentAtIndex: kSegmentNextHole];
		}
		else{
			//[segmentedControl setEnabled:NO forSegmentAtIndex: kSegmentNextHole];
			[self dialogOKCancelAction];
		}
		[deleg.mScore toDB];
		if(deleg.dataHandler){
			if(deleg.device2)
				[deleg.dataHandler sendToDevice:deleg.device2];
			if(deleg.device3)
				[deleg.dataHandler sendToDevice:deleg.device3];
			if(deleg.device4)
				[deleg.dataHandler sendToDevice:deleg.device4];
		}
	}
	else{
		if(((deleg.mScore.gameType==kBackNineEnum) && (deleg.mScore.holeNumber >10)) || ((deleg.mScore.gameType!=kBackNineEnum) && (deleg.mScore.holeNumber >1))){
			deleg.mScore.holeNumber -=1;
		}
		[deleg.mScore toDB];
	}

	[self makeViewTitle];

}


- (void)dialogOKCancelAction
{
	// open a dialog with an OK and cancel button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Game Over"
															 delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Upload to Facebook" otherButtonTitles:@"EMail Score", @"Upload to GolfMemoir.com", @"Finish", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

//@protocol UIActionSheetDelegate <NSObject>
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	if(buttonIndex == 2){
		[deleg.mScore finish];

		User *myUser = [[User alloc] initWithDB:deleg.database];
		if(myUser.userName == nil){
			UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithScore:deleg.mScore]];
			[self presentViewController:dViewC animated:TRUE completion:nil];
			[dViewC release];
		}
		else{
			[deleg.mScore upload: ((myUser.service & kServiceImageUpload) != 0)];
			if((myUser.service & kServiceImageUpload) == 0){
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pay For Photo Upload" message:@"You can store unlimited photos with all your scores on the website. Click the Pay button to buy this option."
															   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Pay", nil];
				[alert show];
				[alert release];
			}
			if(deleg.mScore.serverpk <= 0){ //try again
				UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithScore:deleg.mScore]];
				[self presentViewController:dViewC animated:TRUE completion:nil];
				[dViewC release];
				[(UINavigationController *)[self parentViewController] popToRootViewControllerAnimated:TRUE];
				deleg.tabBarController.selectedIndex=kRoundsTab;
			}
			else{
				[ (UINavigationController *)[self parentViewController] popToRootViewControllerAnimated:TRUE];
				deleg.tabBarController.selectedIndex=kRoundsTab;
				UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[ScoreWebViewController alloc] initWithScore:deleg.mScore]];
				[deleg.tabBarController presentViewController:dViewC animated:TRUE completion:nil];
				[dViewC release];
			}
		}
		
	}
	else if(buttonIndex == 0){
		[deleg.mScore finish];
		User *myUser = [[User alloc] initWithDB:deleg.database];
		if(myUser.userName == nil){
			UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithScore:deleg.mScore]];
			[self presentViewController:dViewC animated:TRUE completion:nil];
			[dViewC release];
		}
		else{
			[deleg.mScore upload:((myUser.service & kServiceImageUpload) != 0)];
			if(deleg.mScore.serverpk <= 0){ //try again
				UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithScore:deleg.mScore]];
				[self presentViewController:dViewC animated:TRUE completion:nil];
				[dViewC release];
			}
			else{
				if(deleg.sessionCache == nil)
				deleg.sessionCache = [FBSession sessionForApplication:kFacebookAppID secret:kFacebookAppSecret delegate:self];
				if([deleg.sessionCache resume] == FALSE){
					FBLoginDialog* ldialog = [[[FBLoginDialog alloc] initWithSession:deleg.sessionCache] autorelease];
					[ldialog show];
				}
				[(UINavigationController *)[self parentViewController] popToRootViewControllerAnimated:TRUE];
				deleg.tabBarController.selectedIndex=kRoundsTab;
			}
		}
	}
	else if(buttonIndex == 1){
		[deleg.mScore finish];
		User *myUser = [[User alloc] initWithDB:deleg.database];
		if(myUser.userName == nil){
			UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithScore:deleg.mScore]];
			[self presentViewController:dViewC animated:TRUE completion:nil];
			[dViewC release];
		}
		else{
			[deleg.mScore upload:((myUser.service & kServiceImageUpload) != 0)];
			if((myUser.service & kServiceImageUpload) == 0){
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pay For Photo Upload" message:@"You can store unlimited photos with all your scores on the website. Click the Pay button to buy this option."
															   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Pay", nil];
				[alert show];
				[alert release];
			}
			if(deleg.mScore.serverpk <= 0){ //try again
				UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithScore:deleg.mScore]];
				[self presentViewController:dViewC animated:TRUE completion:nil];
				[dViewC release];
			}
			else{
				//NSString *url = [NSString stringWithFormat: kEmailURLString, deleg.mScore.serverpk, [[UIDevice currentDevice] uniqueIdentifier]];
				//[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
				[self displayComposerSheet];
			}
		}
	}
	else if(buttonIndex == 3){ //Finish
		[deleg.mScore finish];
		[(UINavigationController *)[self parentViewController] popToRootViewControllerAnimated:TRUE];
		deleg.tabBarController.selectedIndex=kRoundsTab;
	}
	
	
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"You've got GolfMemoir Scorecard!"];
    
	/*
    // Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
    
    [picker setToRecipients:toRecipients];
    
    // Attach an image to the email
    NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
    NSData *myData = [NSData dataWithContentsOfFile:path];
    [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
    */
	
    // Fill out the email body text
 	NSString *emailBody = [NSString stringWithFormat: kEmailBodyString, deleg.mScore.serverpk, [[UIDevice currentDevice] identifierForVendor]];
    [picker setMessageBody:emailBody isHTML:YES];
    
    [self presentViewController:picker animated:YES completion:nil];
    [picker release];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1){
		[deleg.pay requestProductData:kGolfMemoir_PhotoProductIdentifier];
	}
}



- (void)session:(FBSession*)sessionCache didLogin:(FBUID)uid {
	Score *mScore=deleg.mScore;
	FBStreamDialog* dialog = [[[FBStreamDialog alloc] initWithSession:sessionCache] autorelease];
	dialog.delegate = self;
	dialog.userMessagePrompt = @"Share Score Card";
	NSString *url = [NSString stringWithFormat: kGameURLString, mScore.serverpk, [[UIDevice currentDevice] identifierForVendor]];
	NSInteger total=[mScore totalScore:1];
	NSMutableString *players=[[NSMutableString alloc] initWithString:@""];
	if([mScore hasPlayer2]){
		if([mScore hasPlayer3]){
			if([mScore hasPlayer4])
				[players appendFormat: @"with %@, %@ and %@ ", mScore.player2Name, mScore.player3Name, mScore.player4Name];
			else
				[players appendFormat: @"with %@ and %@ ", mScore.player2Name, mScore.player3Name];
		}
		else
			[players appendFormat: @"with %@ ", mScore.player2Name];
	}
	
	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	dateFormat.dateStyle = kCFDateFormatterShortStyle;
	
	dialog.attachment = [NSString stringWithFormat:@"{\"name\":\"Score Card @ %@\",\"href\":\"%@\",\"caption\":\"{*actor*} played golf at %@ %@ on %@.\",\"description\":\"Scored %i.\"}",mScore.mCourse.courseName, url, mScore.mCourse.courseName, players, [dateFormat stringFromDate:mScore.playDate], total];
	dialog.actionLinks = [NSString stringWithFormat:@"[{\"text\":\"Get iPhone App\",\"href\":\"%@\"}]", kGolfMemoirURL];
	[dialog show];
	[dateFormat release];
	
	/*

	FBFeedDialog* dialog = [[[FBFeedDialog alloc] initWithSession:session] autorelease];
	dialog.delegate = self;
	dialog.templateBundleId = kFBStoryTemplateID;
	NSString *url = [NSString stringWithFormat: kGameURLString, deleg.mScore.serverpk, [[UIDevice currentDevice] uniqueIdentifier]];
	NSInteger total=[deleg.mScore totalScore:1];
	NSMutableString *players=[[NSMutableString alloc] initWithString:@""];
	if([deleg.mScore hasPlayer2]){
		if([deleg.mScore hasPlayer3]){
			if([deleg.mScore hasPlayer4])
				[players appendFormat: @"with %@, %@ and %@ ", deleg.mScore.player2Name, deleg.mScore.player3Name, deleg.mScore.player4Name];
			else
				[players appendFormat: @"with %@ and %@ ", deleg.mScore.player2Name, deleg.mScore.player3Name];
		}
		else
			[players appendFormat: @"with %@ ", deleg.mScore.player2Name];
	}

	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	dateFormat.dateStyle = kCFDateFormatterShortStyle;
	
	dialog.templateData = [NSString stringWithFormat:@"{\"course\": \"%@\",\"scorecard\":\"%@\", \"score\": \"%i\",\"players\":\"%@\",\"scoredate\":\"%@\"}", deleg.mScore.mCourse.courseName, url, total, players, [dateFormat stringFromDate:deleg.mScore.playDate]];//{"course": "course","scorecard":"score","score": "100","players":"friend "}
	[dialog show];
	[dateFormat release];
	 */
}


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	if(newLocation !=nil && (deleg.mScore.mCourse.curHole.longitude != 0.0 || deleg.mScore.mCourse.curHole.latitude != 0.0)){
	    if (!signbit(newLocation.horizontalAccuracy)) {
			myScoreDistanceView.text=[formatter stringFromNumber:[NSNumber numberWithDouble:[self getDistance:newLocation]]];
		}
	}
	
	
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	[self dismissViewControllerAnimated:YES completion:nil];
	//[cameraView setBackgroundImage:image forState:UIControlStateNormal];
	UIImage *newImage=[Score scaleAndRotateImage:image];
//	UIImage *newImage=image;
	NSData *imageData = UIImageJPEGRepresentation(newImage, 0.75);
	NSLog(@"orig image height, width:%zi, %zi",CGImageGetHeight(image.CGImage), CGImageGetWidth(image.CGImage));
	NSLog(@"new image height, width:%zi, %zi",CGImageGetHeight(newImage.CGImage), CGImageGetWidth(newImage.CGImage));
	if(imageData != nil){
		NSString *imagePath=[deleg.mScore photoString:TRUE];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error=nil;
		if( [fileManager fileExistsAtPath:imagePath])
			[fileManager removeItemAtPath:imagePath error:&error];
		
		[imageData writeToFile:imagePath options:NSAtomicWrite error:&error];
		if(error == nil){
			NSDictionary *dData = [fileManager attributesOfItemAtPath:imagePath error:&error];
			NSLog(@"%@", imagePath);
			NSLog(@"File size: %qi\n", [[dData objectForKey:@"NSFileSize"] unsignedLongLongValue]);
		}
		else{
			NSLog(@"%@", [error localizedDescription]);
		}
	}
	else{
		NSLog(@"error capturing image");
	}
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[self dismissViewControllerAnimated:YES completion:nil];
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

- (void)viewWillAppear:(BOOL)animated
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    metersBool = [defaults boolForKey:MY_DISTANCE_PREF_KEY];
	if(metersBool){
		myScoreDistanceYard.text = MY_DISTANCE_PREF_MT;
	}
	else{
		myScoreDistanceYard.text = MY_DISTANCE_PREF_YD;
	}
}

- (void)updateDistance:(BOOL) turnOn
{
	if(turnOn){
		myScoreDistanceView.hidden=FALSE;
		myScoreDistanceYard.hidden =FALSE;
		myScoreDistanceButton.hidden=TRUE;
		[clm startUpdatingLocation];
	}
	else{
		myScoreDistanceView.hidden=TRUE;
		myScoreDistanceYard.hidden =TRUE;
		myScoreDistanceButton.hidden = FALSE;
		[clm stopUpdatingLocation];
	}
	
}
- (void)updateScore
{
	myPuttControlView.selectedSegmentIndex = deleg.mScore.curHole.putt;
	[myScoreControlView setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum]] forSegmentAtIndex:1];
	myScoreTotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:1]]];
}
- (void)viewDidAppear:(BOOL)animated
{
	[self updateDistance:FALSE];
	[self updateScore];
}
- (void)viewDidDisappear:(BOOL)animated
{
	[clm stopUpdatingLocation];
}

-(CLLocationDistance) getDistance:(CLLocation *) newLocation
{
	CLLocationDistance dist=0;
	if(newLocation !=nil && (deleg.mScore.mCourse.curHole.longitude != 0.0 || deleg.mScore.mCourse.curHole.latitude != 0.0)){
		CLLocation *holeLoc = [[CLLocation alloc] initWithLatitude:deleg.mScore.mCourse.curHole.latitude longitude:deleg.mScore.mCourse.curHole.longitude ] ;
		dist= [newLocation distanceFromLocation:holeLoc] ;
		if(!metersBool)
			dist = dist * kMeterToYardConversion;
		[holeLoc release];
	}
	return dist;
}


#pragma mark -
#pragma mark ADBannerViewDelegate methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	NSLog(@"bannerViewDidLoadAd");
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
	NSLog(@"didFailToReceiveAdWithError");
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