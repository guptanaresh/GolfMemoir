//
//  ScoreWebViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 11/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "UnlockWebViewController.h"
#import "Constants.h"


@implementation UnlockWebViewController
@synthesize deleg, scoreView, emailButton, cancelButton, myService;

- (id)init:(NSInteger)bService
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		myService=bService;
		// this will appear as the title in the navigation bar
		if((myService & kServiceImageUpload) == 0)
			self.title = @"Pay To Unlock";
		else
			self.title = @"Enable Photo Upload";
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
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"UnlockView" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	/*
	 emailButton = (UIButton *)[cView viewWithTag:kEmailButtonTag];
	 [emailButton addTarget:self action:@selector(emailAction:) forControlEvents:UIControlEventTouchDown];
	 cancelButton = (UIButton *)[cView viewWithTag:kCancelEmailButtonTag];
	 [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchDown];
	 */
	scoreView=(UIWebView *)[cView viewWithTag:kScoreWebViewTag];
	NSString *str;
	if(myService & kServiceUnlock)
		str=[NSString stringWithFormat:@"http://www.golfmemoir.com/unlock.php?udid=%@", [[UIDevice currentDevice] identifierForVendor]];
	else
		str=[NSString stringWithFormat:@"http://www.golfmemoir.com/unlock_photo.php?udid=%@", [[UIDevice currentDevice] identifierForVendor]];
	[scoreView loadRequest:[[[NSURLRequest alloc] initWithURL:[NSURL URLWithString: str]] autorelease]];

	// add our custom add button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithTitle:NSLocalizedString(@" OK ", @"") style:UIBarButtonItemStyleBordered
								  target:self action:@selector(okAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}

- (void)dealloc
{
	[super dealloc];
}

- (void)okAction:(id)sender
{
	User *myUser=[[User alloc] initWithDB:deleg.database];
	[myUser updateService];
	if((myUser.service & myService) == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment not complete yet" message:@"Please click through the payment pages until you get the transaction completion page."
													   delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Try Again", @"Cancel", nil];
		[alert show];
		[alert release];
	}
	else{
		[myUser toDB];
		[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
	}
}	


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0){
	}
	else if(buttonIndex == 1){
		NSString *str;
		if(myService & kServiceUnlock)
			str=[NSString stringWithFormat:@"http://www.golfmemoir.com/unlock.php?udid=%@", [[UIDevice currentDevice] identifierForVendor]];
		else
			str=[NSString stringWithFormat:@"http://www.golfmemoir.com/unlock_photo.php?udid=%@", [[UIDevice currentDevice] identifierForVendor]];
		[scoreView loadRequest:[[[NSURLRequest alloc] initWithURL:[NSURL URLWithString: str]] autorelease]];
	}
	else if(buttonIndex == 2){
		[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
	}		
}


@end