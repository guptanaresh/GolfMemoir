//
//  FacebookFriends.m
//  GolfMemoir
//
//  Created by naresh gupta on 3/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FacebookViewController.h"


@implementation FacebookViewController


- (id)init:(NSInteger)playerNo
{
	if (self = [super init])
	{
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Facebook Friends", @"");
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		fbFriends = [[NSMutableArray alloc] initWithCapacity:0];
		fbFriendsUID = [[NSMutableArray alloc] initWithCapacity:0];
		playerNumber=playerNo;
	}
	currentSelection=nil;
	return self;
}


- (void)loadView
{
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"FacebookView" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	fTableView = (UITableView *)[cView viewWithTag:kFBViewTag];
	fTableView.delegate=self;
	fTableView.dataSource=self;
	/*
	NSArray *segmentTextContent = [NSArray arrayWithObjects: @"Save", @"Cancel", 
								   nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.backgroundColor=[UIColor clearColor];
	
	[segmentedControl addTarget:self action:@selector(lastButtonAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 120, kCustomButtonHeight);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
*/
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											  initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStyleBordered
											  target:self action:@selector(cancelButtonAction:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											  initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStyleBordered
											  target:self action:@selector(saveButtonAction:)];
	
	self.navigationItem.rightBarButtonItem.enabled=FALSE;
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
	FBSession *session = [FBSession sessionForApplication:kFacebookAppID secret:kFacebookAppSecret delegate:self];
	FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:session] autorelease];
	[dialog show];
	
	
}

- (void)cancelButtonAction:(id)sender
{
	[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveButtonAction:(id)sender
{
	[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
	if(currentSelection != nil){
		if(playerNumber==1){
			deleg.mScore.fbUID2 = [[fbFriendsUID objectAtIndex:currentSelection.row] intValue];
			deleg.mScore.player2Name=[[self getAllPeople] objectAtIndex:currentSelection.row];
			[deleg.mScore toDB];
		}
		else if(playerNumber==2){
			deleg.mScore.fbUID3 = [[fbFriendsUID objectAtIndex:currentSelection.row] intValue];
			deleg.mScore.player3Name=[[self getAllPeople] objectAtIndex:currentSelection.row];
			[deleg.mScore toDB];
		}
		else if(playerNumber==3){
			deleg.mScore.fbUID4 = [[fbFriendsUID objectAtIndex:currentSelection.row] intValue];
			deleg.mScore.player4Name=[[self getAllPeople] objectAtIndex:currentSelection.row];
			[deleg.mScore toDB];
		}
		else if(playerNumber==0){
			User *myUser = [[User alloc] initWithDB:deleg.database];
			myUser.fbUID = [[fbFriendsUID objectAtIndex:currentSelection.row] intValue];
			myUser.playerName=[[self getAllPeople] objectAtIndex:currentSelection.row];
			[myUser toDB];
		}
	}
}

- (void)getUserName {
	NSString* fql = [NSString stringWithFormat:@"select name, uid from user where uid in (select uid1 from friend where uid2 = %lli)", fbuid];
	NSLog(@"query: '%@'", fql);
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
}

- (void)request:(FBRequest*)request didLoad:(id)result {
	NSArray* users = result;
	[fbFriends release];
	[fbFriendsUID release];
	fbFriends=[[NSMutableArray alloc] initWithCapacity:[users count]];
	fbFriendsUID=[[NSMutableArray alloc] initWithCapacity:[users count]];
	for(int i=0; i< [users count]; i++){
		NSDictionary* user = [users objectAtIndex:i];
		NSString *name = [user objectForKey:@"name"];
		NSLog(@"name%@", name);
		[fbFriends insertObject:name atIndex:i];
		
		NSNumber *uid = [user objectForKey:@"uid"];
		NSLog(@"uid%i", [uid intValue]);
		[fbFriendsUID insertObject:uid atIndex:i];
	}
	[fTableView reloadData];
}

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	fbuid=uid;
	[self getUserName];
	NSLog(@"User with id %lld logged in.", uid);
}


- (NSArray *)getAllPeople {
	return fbFriends;
}

- (NSString *)stringValueForRow:(NSInteger)row
{
	if(fbFriends != nil){
	NSString *aPerson = [[self getAllPeople] objectAtIndex:row];
	return aPerson;
	}
	else
		return nil;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	if(fbFriends != nil){
		return [fbFriends count];
	}
	else
		return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *MyIdentifier = [@"MyIdentifier" stringByAppendingFormat:@"%i", indexPath.row];
	
	// Try to retrieve from the table view a now-unused cell with the given identifier
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	// If no cell is available, create a new one using the given identifier
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
	}
	// Set up the cell
	cell.textLabel.text = [self stringValueForRow:indexPath.row];
	return cell;
}


- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	if(currentSelection != nil){
		UITableViewCell *oldcell = [theTableView cellForRowAtIndexPath:currentSelection];
		oldcell.accessoryType = UITableViewCellAccessoryNone;
	}
    [theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:newIndexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	currentSelection=newIndexPath;
	self.navigationItem.rightBarButtonItem.enabled=TRUE;
}


- (void)dealloc {
	[super dealloc];
}


@end

