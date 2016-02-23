//
//  GameHoleViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//  access: sr72014323

#import "ListGameDisplayController.h"
#import "GolfMemoirAppDelegate.h"
#import "Constants.h"
#import "LoginViewController.h"
#import "ScoreWebViewController.h"
#import "ScoreCardTable.h"
#import <QuartzCore/QuartzCore.h>

#define PictSize  CGRectMake(0, 90, 320, 380)



@implementation ListGameDisplayController

@synthesize deleg, mScore, tView, addButton, transitionView;


- (id)initWithScore:(Score *)aScore
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg =  (GolfMemoirAppDelegate *)[app delegate];
		// this will appear as the title in the navigation bar
		self.title = [aScore scoreString];
		mScore = aScore;
		mScore.holeNumber=1;
		}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)loadView
{
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
	transitionView = [[[NSBundle mainBundle] loadNibNamed:@"ListGameDisplay" owner:self options:nil] lastObject ];
    [transitionView setDelegate:self];
	[contentView addSubview:transitionView];
	
	ScoreCardTable *cDataSource = [[ScoreCardTable alloc] initWithScore:mScore];
	tView= (UITableView *)[transitionView viewWithTag:kMyScoresViewTag];
	tView.delegate=cDataSource;
	tView.dataSource=cDataSource;
	lastView = tView;
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];

	NSArray *segmentTextContent = [NSArray arrayWithObjects:
								   @"Upload",
								   @"Photo",
								   @"Edit",
								   @"Delete",
								   nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.backgroundColor=[UIColor clearColor];
	
	[segmentedControl addTarget:self action:@selector(listGameMainAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 200, kCustomButtonHeight);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;


	/*
	 addButton = [[UIBarButtonItem alloc]
	 initWithTitle:NSLocalizedString(@"Photos", @"") style:UIBarButtonItemStyleBordered
	 target:self action:@selector(reviewHolesAction:)];
	 
	addButton = [[UIBarButtonItem alloc]
				 initWithTitle:NSLocalizedString(@"Start", @"") style:UIBarButtonItemStyleBordered
				 target:self action:@selector(reviewHolesAction:)];
	stopButton = [[UIBarButtonItem alloc]
				 initWithTitle:NSLocalizedString(@"Stop", @"") style:UIBarButtonItemStyleBordered
				 target:self action:@selector(reviewHolesAction:)];

 addButton = [[UIBarButtonItem alloc]
								  initWithTitle:NSLocalizedString(@"ZapPhotos", @"") style:UIBarButtonItemStyleBordered
								  target:self action:@selector(zapPhotos:)];
	 self.navigationItem.rightBarButtonItem = addButton;
	 */
}


// TransitionViewDelegate methods. 
- (void)transitionViewDidStart:(TransitionView *)view {
}
- (void)transitionViewDidFinish:(TransitionView *)view {
	if(mScore.holeNumber <18){
		mScore.holeNumber=mScore.holeNumber+1;
		[self nextHoleImage];
	}
	if(mScore.holeNumber ==18){
		lastTransitionHole++;
		ScoreCardTable *cDataSource = [[ScoreCardTable alloc] initWithScore:mScore];
		if(lastTransitionHole > 19){
			[transitionView cancelTransition];
		}
		else{
			tView= [[UITableView alloc] initWithFrame:PictSize];
			tView.delegate=cDataSource;
			tView.dataSource=cDataSource;
			[transitionView replaceSubview:lastView withSubview:tView transition:kCATransitionFade direction:kCATransitionFromRight duration:1.0];
			self.title = [mScore scoreString];
			lastView = tView;
		}
	}
		
}
- (void)transitionViewDidCancel:(TransitionView *)view {
}


- (void)zapPhotos:(id)sender
{

	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	 NSArray *files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
	 for(int i=0; i<files.count;i++){
		 NSObject *fl=[files objectAtIndex:i];
		 NSString * fileName = [documentsDirectory stringByAppendingPathComponent:(NSString *)fl];
		 if([fileName hasSuffix:@".jpg"]){
			 NSLog(@"Zapping file:");
			 NSLog(@"%@", fileName);
			 [fileManager removeItemAtPath:fileName error:&error];
		 }
		 else{
			 NSLog(@"Sparing file:");
			 NSLog(@"%@", fileName);
		 }

	 }
}

- (void)listGameMainAction:(id)sender
{
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 1){
		[self reviewHolesAction:sender];
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 2){
		[self editScore:sender];
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 3){
		[self deleteScore:sender];
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		uploadSheet = [[UIActionSheet alloc] initWithTitle:@"Upload"
												  delegate:self cancelButtonTitle:@"EMail" destructiveButtonTitle:@"GolfMemoir.com" otherButtonTitles:@"FaceBook",nil];
		uploadSheet.actionSheetStyle = UIActionSheetStyleDefault;
		[uploadSheet showInView:self.view];
		[uploadSheet release];
	}
}	

- (void)editScore:(id)sender
{
	// open a dialog with an OK and cancel button
	NSInteger curOpen = [Score retrieveOpenGameDatabase: deleg.database];
	if(curOpen > 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You cannot edit this round until you have completed the current round to 18 holes."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else{
		mScore.status=0;
		[mScore toDB];
		deleg.tabBarController.selectedIndex=kHolesTab;
	}
}

- (void)deleteScore:(id)sender
{
	// open a dialog with an OK and cancel button
	NSInteger curOpen = [Score retrieveOpenGameDatabase: deleg.database];
	if(curOpen == mScore.primaryKey){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You cannot delete this round until you have completed the round to 18 holes."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else{
		deleteSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this round?"
												  delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
		deleteSheet.actionSheetStyle = UIActionSheetStyleDefault;
		[deleteSheet showInView:self.view];
		[deleteSheet release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(deleteSheet == actionSheet){
		if(buttonIndex == 0){
			[mScore deleteFromDatabase];
			[[self navigationController] popViewControllerAnimated:YES];
		}
	}
	else if(uploadSheet == actionSheet){
			if(buttonIndex == 0){
				[self upload:actionSheet];
			}
			else if(buttonIndex == 1){
				[self uploadFacebook:actionSheet];
			}
			else if(buttonIndex == 2){
				[self emailAction:actionSheet];
			}
			//[[self navigationController] popViewControllerAnimated:YES];
		}

}

- (void)upload:(id)sender
{
	if(mScore.status == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please finish this round before uploading."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else{
		if(mScore.serverpk > 0){
			User *aUser=[[User alloc] initWithDB:deleg.database];
			if(aUser.udid == nil)
				aUser.udid = [[[UIDevice currentDevice] identifierForVendor] retain];
			[mScore upload:((aUser.service & kServiceImageUpload) != 0)];
			UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[ScoreWebViewController alloc] initWithScore:mScore]];
			[self presentViewController:dViewC animated:TRUE completion:nil];
			[dViewC release];
		}
		else{
			UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithScore:mScore]];
			[self presentViewController:dViewC animated:TRUE completion:nil];
			[dViewC release];
		}
	}
}

- (void)uploadFacebook:(id)sender
{
	if(mScore.status == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please finish this round before uploading."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else{
		User *myUser = [[User alloc] initWithDB:deleg.database];
		if(myUser.userName == nil){
			UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithScore:mScore]];
			[self presentViewController:dViewC animated:TRUE completion:nil];
			[dViewC release];
		}
		else{
			[mScore upload:((myUser.service & kServiceImageUpload) != 0)];
			//UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[ScoreWebViewController alloc] initWithScore:mScore]];
			//[self presentModalViewController:dViewC animated:TRUE];
			//[dViewC release];
			if(mScore.serverpk > 0){
				if(deleg.sessionCache == nil)
					deleg.sessionCache = [FBSession sessionForApplication:kFacebookAppID secret:kFacebookAppSecret delegate:self];
				if([deleg.sessionCache resume] == FALSE){
					FBLoginDialog* ldialog = [[[FBLoginDialog alloc] initWithSession:deleg.sessionCache] autorelease];
				[ldialog show];
				}
			}
			else{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Action Failed" message:@"Please try again."
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
				[alert show];
				[alert release];
			}
		}

	}
}

- (void)session:(FBSession*)sessionCache didLogin:(FBUID)uid {
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
	 FBFeedDialog* dialog = [[[FBFeedDialog alloc] initWithSession:sessionCache] autorelease];
	dialog.delegate = self;
	dialog.templateBundleId = kFBStoryTemplateID;
	NSString *url = [NSString stringWithFormat: kGameURLString, mScore.serverpk, [[UIDevice currentDevice] uniqueIdentifier]];
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
	
	dialog.templateData = [NSString stringWithFormat:@"{\"course\": \"%@\",\"scorecard\":\"%@\", \"score\": \"%i\",\"players\":\"%@\",\"scoredate\":\"%@\"}", mScore.mCourse.courseName, url, total, players, [dateFormat stringFromDate:mScore.playDate]];//{"course": "course","scorecard":"score","score": "100","players":"friend "}
	[dialog show];
	[dateFormat release];
	 */
}



- (void)emailAction:(id)sender{
	User *myUser = [[User alloc] initWithDB:deleg.database];
	if(myUser.userName == nil){
		UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithScore:mScore]];
		[self presentViewController:dViewC animated:TRUE completion:nil];
		[dViewC release];
	}
	else{
		[mScore upload:((myUser.service & kServiceImageUpload) != 0)];
		//UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[ScoreWebViewController alloc] initWithScore:mScore]];
		//[self presentModalViewController:dViewC animated:TRUE];
		//[dViewC release];
		if(mScore.serverpk > 0){
			//NSString *url = [NSString stringWithFormat: kEmailURLString, mScore.serverpk, [[UIDevice currentDevice] uniqueIdentifier]];
			//[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
			[self displayComposerSheet];
		}
		else{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Action Failed" message:@"Please try again."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
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
	 */
	 // Attach an image to the email
	 NSString *path = [[NSBundle mainBundle] pathForResource:@"GolfMemoirMail" ofType:@"jpg"];
	 NSData *myData = [NSData dataWithContentsOfFile:path];
	 [picker addAttachmentData:myData mimeType:@"image/jpg" fileName:@"GolfMemoirMail"];
	 
	
    // Fill out the email body text
 	NSString *emailBody = [NSString stringWithFormat: kEmailBodyString, mScore.serverpk, [[UIDevice currentDevice] identifierForVendor]];
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

- (void)reviewHolesAction:(id)sender
{
	if([self checkImages]){
		if([transitionView isTransitioning]) {
			// Don't interrupt an ongoing transition
			return;
		}
		
		mScore.holeNumber=1;	
		[self nextHoleImage];
	}
	else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photos Not Available" message:@"Remember to take photos when you play the next round."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	
}
-(BOOL)checkImages
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for(int i=1; i<=18; i++){
		mScore.holeNumber=i;
		NSString * imgStr= [mScore photoString:TRUE];
		if([fileManager fileExistsAtPath:imgStr])
			return true;
	}
	return false;
}

-(void) nextHoleImage
{
	for(int i=mScore.holeNumber; i<=18; i++){
		mScore.holeNumber=i;
		lastTransitionHole = mScore.holeNumber;
		NSString * imgStr= [mScore photoString:TRUE];
		UIImage *oldim=[[UIImage alloc] initWithContentsOfFile:imgStr];
		
		if(oldim!=nil){
			UIImage *im=oldim;
			if(CGImageGetWidth(oldim.CGImage) > kMaxResolution){
				im=[Score scaleAndRotateImage:oldim];
				[oldim release];
			}
			NSLog(@"image height, width:%zi, %zi",CGImageGetHeight(im.CGImage), CGImageGetWidth(im.CGImage));
			
			UIImageView *iImageView = [[UIImageView alloc] initWithFrame:PictSize];
			iImageView.image=im;
			self.title=[[NSString alloc] initWithFormat:@"Hole %i", i];
			
			[transitionView replaceSubview:lastView withSubview:iImageView transition:kCATransitionFade direction:kCATransitionFromRight duration:1.0];
			lastView = iImageView;
			break;
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	if(mScore.status == 0){
		[tView reloadData];
	}
}

- (void)viewDidAppear:(BOOL)animated     // Called when the view has been fully transitioned onto the screen. Default does nothing
{
/*
 if(1 == mScore.status){
		[self reviewHolesAction:self];
	}
 */
}
- (void)viewWillDisappear:(BOOL)animated
{	
	if(1 == mScore.status && [transitionView isTransitioning]){
		[transitionView cancelTransition];
	}
}	
@end