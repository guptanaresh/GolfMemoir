//
//  ScoreWebViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 11/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SubscribeViewController.h"
#import "Constants.h"


@implementation SubscribeViewController
@synthesize deleg, mScore, scoreView, emailButton, cancelButton;

- (id)initWithScore:(Score *)aScore
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		// this will appear as the title in the navigation bar
		self.title = [aScore scoreString];
		mScore = aScore;
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
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"SubscribeView" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	/*
	 emailButton = (UIButton *)[cView viewWithTag:kEmailButtonTag];
	 [emailButton addTarget:self action:@selector(emailAction:) forControlEvents:UIControlEventTouchDown];
	 cancelButton = (UIButton *)[cView viewWithTag:kCancelEmailButtonTag];
	 [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchDown];
	 */
	scoreView=(UIWebView *)[cView viewWithTag:kScoreWebViewTag];
	NSString *str=[NSString stringWithFormat:@"http://www.golfmemoir.com/subscribe.php?udid=%@", [[UIDevice currentDevice] identifierForVendor]];
	[scoreView loadRequest:[[[NSURLRequest alloc] initWithURL:[NSURL URLWithString: str]] autorelease]];
	
	// add our custom add button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithTitle:NSLocalizedString(@" OK ", @"") style:UIBarButtonItemStyleBordered
								  target:self action:@selector(cancelAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}


- (void)dealloc
{
	[super dealloc];
}

- (void)cancelAction:(id)sender
{
	[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}	
- (void)emailAction:(id)sender
{
	NSString *url = [NSString stringWithFormat: kEmailURLString, mScore.serverpk, [[UIDevice currentDevice] identifierForVendor]];
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
	//[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}	


@end