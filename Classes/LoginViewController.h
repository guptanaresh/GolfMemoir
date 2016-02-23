//
//  DownloadViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GolfMemoirAppDelegate.h"
#import "Score.h"
#import "Reachability.h"


#define kUploadButtonTag	1
#define kCancelButtonTag	2
#define kUserNameViewTag	3
#define kPasswordViewTag	4
#define kUDIDViewTag		5
#define kRegisterButtonTag	6
#define kUDIDHelpTag		7

#define kUsernameChangeButtonTag		10
#define kPasswordChangeButtonTag		11
#define kUDIDChangeButtonTag		12
#define kPremiumServiceTag		20

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
	UITextField				*userNameView;
	UITextField				*passwordView;
	UITextField				*udidView;
	UIButton				*uploadButton;
	UIButton				*cancelButton;
	UIButton				*registerButton;
	
	GolfMemoirAppDelegate *deleg;
	Score *mScore;
	User *mUser;
	NSInteger	changeUserName;
	NSInteger	changePassword;
	NSInteger	changeUDID;
}

@property (nonatomic, assign) GolfMemoirAppDelegate *deleg;
@property (nonatomic, retain) UITextField				*userNameView;
@property (nonatomic, retain) UITextField				*passwordView;
@property (nonatomic, retain) UITextField				*udidView;
@property (nonatomic, retain) UIButton					*uploadButton;
@property (nonatomic, retain) UIButton					*cancelButton;
@property (nonatomic, retain) UIButton					*registerButton;
@property (nonatomic, retain) Score *mScore;
@property (nonatomic, retain) User *mUser;


- (id)initWithScore:(Score *)aScore;
- (id)initAsTab;
- (void)registerAction:(id)sender;
- (void)uploadAction:(id)sender;
-(void) uploadScore;
-(NSInteger)registerUser;
- (BOOL)validatePassword:(NSString  *)str;
- (BOOL)validateUserName:(NSString  *)str;

@end
