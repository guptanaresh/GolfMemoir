//
//  PeerViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 4/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PeerViewController.h"


@implementation PeerViewController

- (id)init:(NSInteger) playerNo
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		playerNumber=playerNo;
	}
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

	if(deleg.devicesManager == nil){
		deleg.devicesManager = [[BTDevicesManager alloc] init];
		deleg.dataHandler = [[DataHandler alloc] initWithDeviceManager:deleg.devicesManager];
		deleg.sessionManager = [[BTSessionManager alloc] initWithDataHandler:deleg.dataHandler devicesManager:deleg.devicesManager];
		[deleg.sessionManager start];
	}
	// Notifications being called from the BTSessionManager when devices become available/unavailable
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAvailable:) name:NOTIFICATION_DEVICE_AVAILABLE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceUnavailable:) name:NOTIFICATION_DEVICE_UNAVAILABLE object:nil];
	
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
								  target:self action:@selector(cancelButtonAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
}


- (void)deviceAvailable:(NSNotification *)notification {
	[self.tableView reloadData];
	//AudioServicesPlaySystemSound(availableSound);
}

- (void)deviceUnavailable:(NSNotification *)notification {
	[self.tableView reloadData];
	//AudioServicesPlaySystemSound(unavailableSound);
}

- (void)cancelButtonAction:(id)sender
{
[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [deleg.devicesManager.sortedDevices count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DeviceCell";
    
    DeviceCell *cell = (DeviceCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[DeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	BTDevice *device = ((BTDevice *) [deleg.devicesManager.sortedDevices objectAtIndex:indexPath.row]);
	cell.device = device;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DeviceCell *cell = (DeviceCell *) [tableView cellForRowAtIndexPath:indexPath];
	BTDevice *device = cell.device;
	cell.accessoryType=UITableViewCellAccessoryCheckmark;
	if(playerNumber==1){
		deleg.mScore.player2Name=[device deviceName];
		deleg.device2=device;
	}
	else if(playerNumber==2){
		deleg.mScore.player3Name=[device deviceName];;
		deleg.device3=device;
	}
	else if(playerNumber==3){
		deleg.mScore.player4Name=[device deviceName];;
		deleg.device4=device;
	}
	[deleg.mScore toDB];
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

