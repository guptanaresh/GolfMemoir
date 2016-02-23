//
//  GameHoleViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GolfMemoirAppDelegate.h"
#import "TransitionView.h"
#import "ListGameDisplayController.h"
#import "FBConnect/FBConnect.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define kImageViewTag			5
#define kMyScoresViewTag		2




#define kSegmentCamera		4
#define kSegmentNextStroke	3
#define kSegmentPrevStroke	2
#define kSegmentNextHole	1
#define kSegmentPrevHole	0


@interface ListGameDisplayController : UIViewController<MFMailComposeViewControllerDelegate, TransitionViewDelegate, UIActionSheetDelegate, FBSessionDelegate, FBDialogDelegate>
{
	UITableView				*tView;
//	UIImageView				*iView;
	TransitionView			*transitionView;
	NSInteger				lastTransitionHole;
	GolfMemoirAppDelegate *deleg;
	Score *mScore;
	UIBarButtonItem *addButton;
	UIBarButtonItem *stopButton;
	UIView *lastView;
	UIActionSheet *deleteSheet;
	UIActionSheet *uploadSheet;
}

@property (nonatomic, retain) TransitionView			*transitionView;
@property (nonatomic, retain) UITableView *tView;
@property (nonatomic, assign) GolfMemoirAppDelegate *deleg;
@property (nonatomic, assign) Score *mScore;
@property (nonatomic, assign) UIBarButtonItem *addButton;

- (id)initWithScore:(Score *)aScore;
- (void)deleteScore:(id)sender;
- (void)upload:(id)sender;
- (void)emailAction:(id)sender;
- (void)reviewHolesAction:(id)sender;
-(void) nextHoleImage;
-(BOOL)checkImages;
- (void)uploadFacebook:(id)sender;


@end
