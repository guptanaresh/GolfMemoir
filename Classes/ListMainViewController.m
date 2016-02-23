//
//  ListMainViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/6/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import "ListMainViewController.h"
#import "ListGameDisplayController.h"
#import "Constants.h"


@implementation ListMainViewController

@synthesize myTableView, scoreList, deleg, bannerVisible, banner;

static NSString *kCellIdentifier = @"ListViewIdentifier";

- (id)init
{
	if (self = [super init])
	{
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Rounds", @"");
		
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		self.scoreList = [Score retrieveAllFinishedScores:deleg.database];
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
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"ListMain" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	myTableView = (UITableView *)[cView viewWithTag:1];
	myTableView.delegate=self;
	myTableView.dataSource=self;

	NSArray *segmentTextContent = [NSArray arrayWithObjects:
								   @"Handicap Index",
								   nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.backgroundColor=[UIColor clearColor];
	
	[segmentedControl addTarget:self action:@selector(listGameMainAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 100, kCustomButtonHeight);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
	
	banner = (ADBannerView *)[cView viewWithTag:kADBannerView];
	banner.delegate=self;
	bannerVisible=TRUE;
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}


- (void)dealloc
{
	banner.delegate=nil;
	[scoreList release];
	[myTableView release];
	
	[super dealloc];
}

- (void)listGameMainAction:(id)sender
{
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		double hi = [Score calcHandicapIndex];
		NSString *hcpStr;
		if(hi == kInvalidHI)
			hcpStr=@"You need at least 5 rounds for establishing Handicap Index.";
		else
			hcpStr=[NSString  stringWithFormat:@"Your Handicap Index is %2.1f", hi];

		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Handicap Index" message:hcpStr
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
}	


#pragma mark UIViewController delegate methods

- (void)viewWillAppear:(BOOL)animated
{
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [myTableView indexPathForSelectedRow];
	[myTableView deselectRowAtIndexPath:tableSelection animated:NO];
	self.scoreList = [Score retrieveAllFinishedScores:deleg.database];
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
	UIViewController *targetViewController = [[ListGameDisplayController alloc] initWithScore:[scoreList objectAtIndex: indexPath.row]];
	[[self navigationController] pushViewController:targetViewController animated:YES];
}


#pragma mark UITableView datasource methods

// tell our table how many rows it will have, in our case the size of our scoreList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [scoreList count];
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
	}
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	
	Score	*aScore = [ ((ListMainViewController *)tableView.delegate).scoreList objectAtIndex:indexPath.row];
	if(aScore != nil){
        cell.textLabel.text = [aScore scoreString];
        return cell;
    }
    else
        return nil;
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
        cbanner.frame = CGRectOffset(banner.frame, 0, -50);
		//banner.hidden = TRUE;
		self.bannerVisible=FALSE;
        [UIView commitAnimations];
    }
}




@end