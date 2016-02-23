//
//  FVMainViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import "GameFriendPicker.h"
#import "FacebookViewController.h"
#import "GolfMemoirAppDelegate.h"
#import "Constants.h"
#import "Reachability.h"
#import "FacebookViewController.h"
#import "PeerViewController.h"


@implementation GameFriendPicker

@synthesize deleg;


#define kStdButtonWidth 150

- (id)init:(NSInteger)playerNo
{
	if (self = [super init])
	{
		// this will appear as the title in the navigation bar
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		playerNumber=playerNo;
		if(playerNumber==0){
			self.title = NSLocalizedString(@"First Player", @"");
		}
		else if(playerNumber==1){
			self.title = NSLocalizedString(@"Second Player", @"");
		}
		else if(playerNumber==2){
			self.title = NSLocalizedString(@"Third Player", @"");
		}
		else if(playerNumber==3){
			self.title = NSLocalizedString(@"Fourth Player", @"");
		}
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
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"FriendView" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	hiView = (UITextField *)[cView viewWithTag:kHandicapIndexTag];
	playerLabel = (UILabel *)[cView viewWithTag:kPlayerNameTag];

	/*
	UIButton *but1 = (UIButton *)[cView viewWithTag:kSelectContactButtonTag];
	[but1 addTarget:self action:@selector(selectContactAction:) forControlEvents:UIControlEventTouchUpInside];
	UIButton *but2 = (UIButton *)[cView viewWithTag:kAddContactButtonTag];
	[but2 addTarget:self action:@selector(addContactAction:) forControlEvents:UIControlEventTouchUpInside];
	UIButton *but3 = (UIButton *)[cView viewWithTag:kFacebookButtonTag];
	[but3 addTarget:self action:@selector(facebookAction:) forControlEvents:UIControlEventTouchUpInside];
*/	
	
	UISegmentedControl *contactToggle = (UISegmentedControl *)[cView viewWithTag:kPlayersOrContactsToggleTag];
	[contactToggle addTarget:self action:@selector(changeToContactsAction:) forControlEvents:UIControlEventValueChanged];
	 

	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											 initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStyleBordered
											 target:self action:@selector(cancelButtonAction:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											  initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStyleBordered
											  target:self action:@selector(saveButtonAction:)];
	
	[self refreshContent];
	
	
	
}



- (void)viewDidAppear:(BOOL)animated
{
	[self refreshContent];
}
- (void)viewWillAppear:(BOOL)animated
{
	[self refreshContent];
}

-(void)refreshContent
{
	if(playerNumber==0){
		User *myUser = [[User alloc] initWithDB:deleg.database];
		hiView.text=[NSString stringWithFormat:@"%2.1f",myUser.latestHI];
		playerLabel.text=myUser.playerName;
	}
	else if(playerNumber==1){
		playerLabel.text=deleg.mScore.player2Name;
		hiView.text=[NSString stringWithFormat:@"%2.1f",deleg.mScore.hi2];
	}
	else if(playerNumber==2){
		playerLabel.text=deleg.mScore.player3Name;
		hiView.text=[NSString stringWithFormat:@"%2.1f",deleg.mScore.hi3];
	}
	else if(playerNumber==3){
		playerLabel.text=deleg.mScore.player4Name;
		hiView.text=[NSString stringWithFormat:@"%2.1f",deleg.mScore.hi4];
	}
	if(playerLabel.text !=nil){
		self.navigationItem.rightBarButtonItem.enabled=TRUE;
	}
	else{
		self.navigationItem.rightBarButtonItem.enabled=FALSE;
	}

}

- (void)cancelButtonAction:(id)sender
{
	if(playerNumber==1){
		deleg.mScore.hi2=0;
		deleg.mScore.player2Name=nil;
	}
	else if(playerNumber==2){
		deleg.mScore.hi3=0;
		deleg.mScore.player3Name=nil;
	}
	else if(playerNumber==3){
		deleg.mScore.hi4=0;
		deleg.mScore.player4Name=nil;
	}
	else if(playerNumber==0){
		deleg.mScore.hi=0;
		User *myUser = [[User alloc] initWithDB:deleg.database];
		myUser.contactID = 0;
		myUser.playerName=nil;
		[myUser toDB];
	}
	[deleg.mScore toDB];
	[[self navigationController] popViewControllerAnimated:YES];
}
- (void)saveButtonAction:(id)sender
{
	if(playerNumber==1){
		deleg.mScore.hi2=[hiView.text doubleValue];
	}
	else if(playerNumber==2){
		deleg.mScore.hi3=[hiView.text doubleValue];
	}
	else if(playerNumber==3){
		deleg.mScore.hi4=[hiView.text doubleValue];
	}
	else if(playerNumber==0){
		deleg.mScore.hi=[hiView.text doubleValue];
	}
	[deleg.mScore toDB];
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)changeToContactsAction:(id)sender
{
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		[self selectContactAction:sender];
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 1){
		[self addContactAction:sender];
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 2){
		[self facebookAction:sender];
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 3){
		[self peerAction:sender];
	}

}	

- (void)peerAction:(id)sender
{
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[PeerViewController alloc] init:playerNumber]];
	[self presentViewController:dViewC animated:TRUE completion:nil];
	[dViewC release];
}


- (void)selectContactAction:(id)sender
{
	ABPeoplePickerNavigationController *ab=[[ABPeoplePickerNavigationController alloc] init];
	ab.peoplePickerDelegate=self;
	[self presentViewController:ab animated:TRUE completion:nil];
}

- (void)addContactAction:(id)sender
{
	ABNewPersonViewController *ab=[[ABNewPersonViewController alloc] init];
	ab.newPersonViewDelegate=self;
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:ab];
	[self presentViewController:dViewC animated:TRUE completion:nil];
}
- (void)facebookAction:(id)sender
{
	if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Can't connect to Facebook. Please try again when you have internet connection."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else{
		UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[FacebookViewController alloc] init:playerNumber]];
		[self presentViewController:dViewC animated:TRUE completion:nil];
		[dViewC release];
	}
}


-(void) resignKeyboard
{
	[hiView resignFirstResponder];
	
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


- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[newPersonViewController dismissViewControllerAnimated:YES completion:nil];
	if(person != NULL){
		if(playerNumber==1){
			deleg.mScore.hi2=[hiView.text doubleValue];
			deleg.mScore.player2Name=(NSString *)ABRecordCopyCompositeName(person);
		}
		else if(playerNumber==2){
			deleg.mScore.hi3=[hiView.text doubleValue];
			deleg.mScore.player3Name=(NSString *)ABRecordCopyCompositeName(person);
		}
		else if(playerNumber==3){
			deleg.mScore.hi4=[hiView.text doubleValue];
			deleg.mScore.player4Name=(NSString *)ABRecordCopyCompositeName(person);
		}
		else if(playerNumber==0){
			deleg.mScore.hi=[hiView.text doubleValue];
			User *myUser = [[User alloc] initWithDB:deleg.database];
			myUser.contactID = ABRecordGetRecordID(person);
			myUser.playerName=(NSString *)ABRecordCopyCompositeName(person);
			[myUser toDB];
		}
		[deleg.mScore toDB];
		//[[self navigationController] popViewControllerAnimated:YES];
	}
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    
	[peoplePicker dismissViewControllerAnimated:YES completion:nil];
	if(person != NULL){
		if(playerNumber==1){
			deleg.mScore.hi2=[hiView.text doubleValue];
			deleg.mScore.player2Name=(NSString *)ABRecordCopyCompositeName(person);
		}
		else if(playerNumber==2){
			deleg.mScore.hi3=[hiView.text doubleValue];
			deleg.mScore.player3Name=(NSString *)ABRecordCopyCompositeName(person);
		}
		else if(playerNumber==3){
			deleg.mScore.hi4=[hiView.text doubleValue];
			deleg.mScore.player4Name=(NSString *)ABRecordCopyCompositeName(person);
		}
		else if(playerNumber==0){
			deleg.mScore.hi=[hiView.text doubleValue];
			User *myUser = [[User alloc] initWithDB:deleg.database];
			myUser.contactID = ABRecordGetRecordID(person);
			myUser.playerName=(NSString *)ABRecordCopyCompositeName(person);
			[myUser toDB];
		}
		[deleg.mScore toDB];
		//[[self navigationController] popViewControllerAnimated:YES];
	}
	return YES;
    
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	[peoplePicker dismissViewControllerAnimated:YES completion:nil];
	if(person != NULL){
		if(playerNumber==1){
			deleg.mScore.hi2=[hiView.text doubleValue];
			deleg.mScore.player2Name=(NSString *)ABRecordCopyCompositeName(person);
		}
		else if(playerNumber==2){
			deleg.mScore.hi3=[hiView.text doubleValue];
			deleg.mScore.player3Name=(NSString *)ABRecordCopyCompositeName(person);
		}
		else if(playerNumber==3){
			deleg.mScore.hi4=[hiView.text doubleValue];
			deleg.mScore.player4Name=(NSString *)ABRecordCopyCompositeName(person);
		}
		else if(playerNumber==0){
			deleg.mScore.hi=[hiView.text doubleValue];
			User *myUser = [[User alloc] initWithDB:deleg.database];
			myUser.contactID = ABRecordGetRecordID(person);
			myUser.playerName=(NSString *)ABRecordCopyCompositeName(person);
			[myUser toDB];
		}
		[deleg.mScore toDB];
		//[[self navigationController] popViewControllerAnimated:YES];
	}
	return YES;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	[peoplePicker dismissViewControllerAnimated:YES completion:nil];
}
@end