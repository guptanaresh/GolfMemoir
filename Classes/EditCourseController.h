//
//  GameHoleViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GolfMemoirAppDelegate.h"
#import <iAd/iAd.h>//;
#import "EditLocationController.h"
#import "Constants.h"
#import "ScoreCardTable.h"

#define kHoleTableTag				1
#define kNameViewTag				2
#define kAddressViewTag				3
#define kCityViewTag				4
#define kStateViewTag				5
#define kCountryViewTag				6
#define kPhoneViewTag				7
#define kURLViewTag					8
#define kZipViewTag					9

#define kURLButtonTag					10
#define kPhoneButtonTag					11
#define kPhoneLabelTag					12

#define kBlackCourseRatingViewTag					50
#define kBlueCourseRatingViewTag					51
#define kWhiteCourseRatingViewTag					52
#define kOrangeCourseRatingViewTag					53
#define kBlackSlopeRatingViewTag					60
#define kBlueSlopeRatingViewTag					61
#define kWhiteSlopeRatingViewTag					62
#define kOrangeSlopeRatingViewTag					63


#define kADBannerView			70



#define k10Spaces					@"          "
#define k5Spaces					@"     "


#define LEFT_COLUMN_OFFSET 0.0
#define LEFT_COLUMN_WIDTH 50.0

#define MIDDLE_COLUMN_OFFSET 40.0
#define MIDDLE_COLUMN_WIDTH 120.0

#define RIGHT_COLUMN_OFFSET 172.0
#define RIGHT_COLUMN_WIDTH 50

#define FOURTH_COLUMN_OFFSET 232.0
#define FOURTH_COLUMN_WIDTH 80

#define MAIN_FONT_SIZE 18.0
#define EDIT_LABEL_HEIGHT 16.0
#define EDIT_ROW_HEIGHT 32


@interface EditCourseController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate, ADBannerViewDelegate>
{
	UITableView				*tView;
	UIView					*cView;
	UITextField				*nameView;
	UITextField				*addressView;
	UITextField				*cityView;
	UITextField				*stateView;
	UITextField				*countryView;
	UITextField				*phoneView;
	UITextField				*urlView;
	UITextField				*zipView;
	GolfMemoirAppDelegate *deleg;
	Course *mCourse;
	UIActionSheet *backupActionSheet;
	UIActionSheet *validateActionSheet;
	ADBannerView *adMobAd;   // the actual ad; self.view is the location where the ad will be placed
	BOOL	showIncompleteWarning;
	UIAlertView *inCompleteAlert;
	CLLocationManager *clm;
	NSInteger		 numPlacemark;
	NSDictionary	*placemarkDict;
	UIAlertView *placemarkAlert;
	BOOL bannerVisible;
}

@property (nonatomic, retain) UITableView *tView;
@property (nonatomic, retain) UIView					*cView;
@property (nonatomic, retain) UITextField				*nameView;
@property (nonatomic, retain) UITextField				*addressView;
@property (nonatomic, retain) UITextField				*cityView;
@property (nonatomic, retain) UITextField				*stateView;
@property (nonatomic, retain) UITextField				*countryView;
@property (nonatomic, retain) UITextField				*phoneView;
@property (nonatomic, retain) UITextField				*urlView;
@property (nonatomic, retain) UITextField				*zipView;
@property (nonatomic, retain) GolfMemoirAppDelegate *deleg;
@property (nonatomic, retain) Course *mCourse;
@property (nonatomic, assign) BOOL bannerVisible;

- (id)initWithCourse:(Course *)aCourse;
-(BOOL)courseNameValidate:(NSString *)name;

@end
