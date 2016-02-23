//
//  ScoreWebViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 11/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GolfMemoirAppDelegate.h"
#import "Score.h"
#import "Reachability.h"

#define kScoreWebViewTag	1
#define kEmailButtonTag	2
#define kCancelEmailButtonTag	3



@interface ScoreWebViewController : UIViewController {
	GolfMemoirAppDelegate	*deleg;
	UIWebView				*scoreView;	
	UIButton				*emailButton;
	UIButton				*cancelButton;

	Score *mScore;
}

@property (nonatomic, assign) GolfMemoirAppDelegate *deleg;
@property (nonatomic, assign) Score *mScore;
@property (nonatomic, assign) UIWebView				*scoreView;
@property (nonatomic, retain) UIButton					*emailButton;
@property (nonatomic, retain) UIButton					*cancelButton;

- (id)initWithScore:(Score *)aScore;

@end
	
