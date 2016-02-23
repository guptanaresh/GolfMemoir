//
//  GameHoleViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GolfMemoirAppDelegate.h"
#import <CoreLocation/CoreLocation.h>//;
#import <iAd/iAd.h>//;
#import "FBConnect/FBConnect.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


#define kParControlViewTag				1
#define kYardageViewTag					2
#define kMyScoreControlViewTag			3
#define kMyScoreDistanceViewTag			4
#define kMyScoreTotalViewTag			5
#define kMyScorePuttOrDriveViewTag		6
#define kPinLocationButtonTag			7
#define kMyScoreDistanceYardTag			8


#define kPlayer2ControlViewTag		10
#define kPlayer2LabelViewTag		12
#define kPlayer2TotalViewTag		11

#define kPlayer3ControlViewTag		20
#define kPlayer3LabelViewTag		22
#define kPlayer3TotalViewTag		21

#define kPlayer4ControlViewTag		30
#define kPlayer4LabelViewTag		32
#define kPlayer4TotalViewTag		31


#define kPhotoViewTag			41


#define kHoleDataViewTag			50
#define kMyScoreViewTag				51
#define kPlayer2ScoreViewTag		52
#define kPlayer3ScoreViewTag		53
#define kPlayer4ScoreViewTag		54


#define kHelpTextTag			60

#define kADBannerView			70



#define kSegmentCamera		4
#define kSegmentNextHole	1
#define kSegmentPrevHole	0


@interface GameHoleViewController : UIViewController <MFMailComposeViewControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, FBSessionDelegate, FBDialogDelegate, ADBannerViewDelegate>
{
	GolfMemoirAppDelegate *deleg;
	UISegmentedControl *myPuttControlView;
	UISegmentedControl *myScoreControlView;
	UITextField *myScoreDistanceView;
	UILabel *myScoreDistanceYard;
	UIButton *myScoreDistanceButton;
	UILabel *myScoreTotalView;
	UIView *cView;
	UIView *panel2View;
	UISegmentedControl *player2ControlView;
	UILabel *player2TotalView;
	UIView *panel3View;
	UISegmentedControl *player3ControlView;
	UILabel *player3TotalView;
	UIView *panel4View;
	UISegmentedControl *player4ControlView;
	UILabel *player4TotalView;
	UIButton *cameraView;
	UISegmentedControl *segmentedControl;
	NSNumberFormatter *formatter;
	CLLocationManager *clm;
	BOOL metersBool;
	BOOL bannerVisible;
	UIAlertView *locationAlertView;
	UILabel *helpText;
}

@property (nonatomic, assign) GolfMemoirAppDelegate *deleg;
@property (nonatomic, assign) UISegmentedControl *myPuttControlView;
@property (nonatomic, assign) UISegmentedControl *myScoreControlView;
@property (nonatomic, assign) UITextField *myScoreDistanceView;
@property (nonatomic, assign) UILabel *myScoreDistanceYard;
@property (nonatomic, assign) UIButton *myScoreDistanceButton;
@property (nonatomic, assign) UILabel *myScoreTotalView;
@property (nonatomic, assign) UIView *cView;
@property (nonatomic, assign) UIView *panel2View;
@property (nonatomic, assign) UISegmentedControl *player2ControlView;
@property (nonatomic, assign) UILabel *player2TotalView;
@property (nonatomic, assign) UIView *panel3View;
@property (nonatomic, assign) UISegmentedControl *player3ControlView;
@property (nonatomic, assign) UILabel *player3TotalView;
@property (nonatomic, assign) UIView *panel4View;
@property (nonatomic, assign) UISegmentedControl *player4ControlView;
@property (nonatomic, assign) UILabel *player4TotalView;
@property (nonatomic, assign) UIButton *cameraView;
@property (nonatomic, assign) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) BOOL metersBool;
@property (nonatomic, assign) BOOL bannerVisible;
@property (nonatomic, assign) UILabel *helpText;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo;
- (void)changeHole:(BOOL)up;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)makeViewTitle;
- (void)playerControlAction:(id)sender  playerNo:(NSInteger) which;
- (void)dialogOKCancelAction;
-(CLLocationDistance) getDistance:(CLLocation *) newLocation;
- (void)updateDistance:(BOOL) turnOn;

@end
