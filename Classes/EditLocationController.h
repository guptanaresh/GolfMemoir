//
//  GameHoleViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GolfMemoirAppDelegate.h"
#import "HolePickerView.h"
#import <iAd/iAd.h>//;


#define kHoleTypeViewTag				2
#define kHoleTypeButtonTag				3
#define kLongViewTag				5
#define kLatViewTag				4
#define kTeeLatViewTag				10
#define kTeeLongViewTag				11
#define kPinLatViewTag				12
#define kPinLongViewTag				13
#define kFrontPinLatViewTag				14
#define kFrontPinLongViewTag				15
#define kBackPinLatViewTag				16
#define kBackPinLongViewTag				17
#define kTeeButtonTag				18
#define kPinButtonTag				19
#define kFrontPinButtonTag				20
#define kBackPinButtonTag				21

#define kParSliderTag				30
#define kParLabelTag				31
#define kHcpSliderTag				32
#define kHcpLabelTag				33


#define kBlackViewTag				50
#define kBlueViewTag				51
#define kWhiteViewTag				52
#define kRedViewTag					53
#define kYardTextViewTag			54

#define kHoleLayout					60

#define kParrControlViewTag			70
#define kHcpControlViewTag			71

#define kADBannerViewLocation			80


@interface EditLocationController : UIViewController<ADBannerViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, CLLocationManagerDelegate>
{
	GolfMemoirAppDelegate *deleg;
	Course *mCourse;
	UISlider	*parView;
	UILabel		*parLabel;
	UISegmentedControl *parControlView;
	UISegmentedControl *hcpControlView;
	UISlider	*hcpView;
	UILabel		*hcpLabel;
	UITextField	*blackView;
	UITextField	*blueView;
	UITextField	*whiteView;
	UITextField	*redView;
	UISegmentedControl *holeLayout;
	UITextField	*longView;
	UITextField	*latView;
	UIView	*cView;
	NSNumberFormatter *formatter;
	NSArray *holeTypeArray;
	CLLocationManager *clm;
	ADBannerView *adMobAd;   // the actual ad; self.view is the location where the ad will be placed
	BOOL	showIncompleteWarning;
	UIAlertView *inCompleteAlert;
	BOOL bannerVisible;
}

@property (nonatomic, retain) UISlider				*parView;
@property (nonatomic, retain) UISegmentedControl				*parControlView;
@property (nonatomic, retain) UISegmentedControl				*hcpControlView;
@property (nonatomic, retain) UILabel				*parLabel;
@property (nonatomic, retain) UISlider				*hcpView;
@property (nonatomic, retain) UILabel				*hcpLabel;
@property (nonatomic, retain) UITextField				*blackView;
@property (nonatomic, retain) UITextField				*blueView;
@property (nonatomic, retain) UITextField				*whiteView;
@property (nonatomic, retain) UITextField				*redView;
@property (nonatomic, retain) UITextField				*longView;
@property (nonatomic, retain) UITextField				*latView;
@property (nonatomic, retain) GolfMemoirAppDelegate *deleg;
@property (nonatomic, retain) Course *mCourse;
@property (nonatomic, assign) BOOL bannerVisible;

- (id)initWithCourse:(Course *)aCourse;
-(void)makeViewTitle;
- (void)changeHole:(BOOL)up;
-(void)refreshLocations;
-(void) resignKeyboard;

@end
