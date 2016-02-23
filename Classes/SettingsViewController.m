//
//  PrivacyViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 9/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "Constants.h"


@implementation SettingsViewController


- (id)init
{
	if (self = [super init])
	{
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Settings", @"");
	}
	return self;
}


- (void)loadView
{
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"settings" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];

	UIButton *changeButton = (UIButton *)[cView viewWithTag:kChangeButtonTag];
	[changeButton addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchDown];

	UISwitch *distButton = (UISwitch *)[cView viewWithTag:kDistancePrefButtonTag];
	[distButton addTarget:self action:@selector(changeDistancePrefAction:) forControlEvents:UIControlEventTouchDown];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[distButton setOn:[defaults boolForKey:MY_DISTANCE_PREF_KEY]];
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}

- (void)changeAction:(id)sender
{
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initAsTab]];
	[self presentViewController:dViewC animated:TRUE completion:nil];
	[dViewC release];
}

- (void)changeDistancePrefAction:(id)sender
{
	UISwitch *distButton=(UISwitch *)sender;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL state=!distButton.on;
	[defaults setBool:state forKey:MY_DISTANCE_PREF_KEY];
	[defaults synchronize];
}
- (void)dealloc
{
	
	[super dealloc];
}


@end

