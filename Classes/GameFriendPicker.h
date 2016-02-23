//
//  FVMainViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameHoleViewController.h"
#import "Course.h"
#import "FBConnect/FBConnect.h"
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/ABNewPersonViewController.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <GameKit/GKPeerPickerController.h>
#import <GameKit/GKSession.h>

#define kPlayersOrContactsToggleTag	10
//#define kSelectContactButtonTag	10
//#define kAddContactButtonTag	11
//#define kFacebookButtonTag	12
#define kPlayerNameTag	13
#define kHandicapIndexTag	20


@interface GameFriendPicker : UIViewController <UITextFieldDelegate, ABNewPersonViewControllerDelegate,  ABPeoplePickerNavigationControllerDelegate, GKPeerPickerControllerDelegate, GKSessionDelegate>
{
	UITextField			*hiView;
	UILabel *playerLabel;
	NSInteger			playerNumber;
	GolfMemoirAppDelegate *deleg;
}

@property (nonatomic, assign) GolfMemoirAppDelegate *deleg;

-(void) resignKeyboard;
- (id)init:(NSInteger)playerNo;
-(void)refreshContent;
- (void)selectContactAction:(id)sender;
- (void)addContactAction:(id)sender;
- (void)facebookAction:(id)sender;

@end
