//
//  ListMainViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import "GameFriendsViewController.h"
#import "Constants.h"
#import "Reachability.h"


@implementation GameFriendsViewController

@synthesize myTableView, deleg, bannerVisible, banner, playerList;

static NSString *kCellIdentifier = @"GameFriendsViewController";

- (id)init
{
	if (self = [super init])
	{
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Players", @"");
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
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
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"FriendsMain" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	myTableView = (UITableView *)[cView viewWithTag:kFriendTableViewTag];
	myTableView.delegate=self;
	myTableView.dataSource=self;
	
	banner = (ADBannerView *)[cView viewWithTag:kADBannerView];
	banner.delegate=self;
	bannerVisible=TRUE;
	
	
	// add our custom add button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithTitle:NSLocalizedString(@"Start Game", @"") style:UIBarButtonItemStyleBordered
								  target:self action:@selector(nextAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}

- (void)nextAction:(id)sender
{
	// the add button was clicked, handle it here
	BOOL scoreDirty=FALSE;
	if((![deleg.mScore hasPlayer2]) && [deleg.mScore hasPlayer3]){
		deleg.mScore.player2Name=deleg.mScore.player3Name;
		deleg.mScore.hi2=deleg.mScore.hi3;
		deleg.mScore.fbUID2=deleg.mScore.fbUID3;
		deleg.mScore.player3Name=nil;
		deleg.mScore.hi3=0;
		deleg.mScore.fbUID3=0;
		scoreDirty=TRUE;
	}
	
	if((![deleg.mScore hasPlayer3]) && [deleg.mScore hasPlayer4]){
		deleg.mScore.player3Name=deleg.mScore.player4Name;
		deleg.mScore.hi3=deleg.mScore.hi4;
		deleg.mScore.fbUID3=deleg.mScore.fbUID4;
		deleg.mScore.player4Name=nil;
		deleg.mScore.hi4=0;
		deleg.mScore.fbUID4=0;
		scoreDirty=TRUE;
	}
	if(scoreDirty==TRUE)
		[deleg.mScore toDB];

	holeController = [[GameHoleViewController alloc] init];	
	[[self navigationController] pushViewController:holeController animated:TRUE];
	
}

- (void)dealloc
{
	banner.delegate=nil;
	[myTableView release];
	
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated
{
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [myTableView indexPathForSelectedRow];
	[myTableView deselectRowAtIndexPath:tableSelection animated:NO];
	[myTableView reloadData];
}


#pragma mark UITableView delegate methods
// tell our table how many sections or groups it will have (always 1 in our case)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UIViewController *targetViewController = [[GameFriendPicker alloc] init:indexPath.row];
	[[self navigationController] pushViewController:targetViewController animated:YES];
}


#pragma mark UITableView datasource methods

// tell our table how many rows it will have, in our case the size of our playerList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 4;
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
	}
	cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	
	if(indexPath.row ==0){
		User *myUser = [[User alloc] initWithDB:deleg.database];
		if(myUser.playerName == nil)
			cell.textLabel.text = [NSString stringWithFormat:@"First Player: me"];
		else
			cell.textLabel.text = [NSString stringWithFormat:@"First Player: %@", myUser.playerName];
	}
	else if(indexPath.row ==1){
		if(deleg.mScore.player2Name)
			cell.textLabel.text = [NSString stringWithFormat:@"Second Player: %@", deleg.mScore.player2Name];
		else
			cell.textLabel.text = [NSString stringWithFormat:@"Second Player:"];
	}
	else if (indexPath.row ==2){
		if(deleg.mScore.player3Name)
			cell.textLabel.text = [NSString stringWithFormat:@"Third Player: %@", deleg.mScore.player3Name];
		else
			cell.textLabel.text = [NSString stringWithFormat:@"Third Player:"];
	}
	else if(indexPath.row ==3){
		if(deleg.mScore.player4Name)
			cell.textLabel.text = [NSString stringWithFormat:@"Fourth Player: %@", deleg.mScore.player4Name];
		else
			cell.textLabel.text = [NSString stringWithFormat:@"Fourth Player:"];
	}
	return cell;
}

#pragma mark -
#pragma mark ADBannerViewDelegate methods
- (void)bannerViewDidLoadAd:(ADBannerView *)cbanner
{
	
    if (!self.bannerVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        //banner.hidden = NO;
		// assumes the banner view is offset 50 pixels so that it is not visible.
        cbanner.frame = CGRectOffset(cbanner.frame, 0, 50);
		bannerVisible=TRUE;
        [UIView commitAnimations];
    }
}
- (void)bannerView:(ADBannerView *)cbanner didFailToReceiveAdWithError:(NSError *)error
{
	if (self.bannerVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
        cbanner.frame = CGRectOffset(cbanner.frame, 0, -50);
		//banner.hidden = TRUE;
		self.bannerVisible=FALSE;
        [UIView commitAnimations];
    }
}



@end