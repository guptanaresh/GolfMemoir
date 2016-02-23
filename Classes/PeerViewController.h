//
//  PeerViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 4/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GolfMemoirAppDelegate.h"
#import "DataHandler.h"
#import "BTDevicesManager.h"
#import "DeviceCell.h"


@interface PeerViewController : UITableViewController {
	NSInteger			playerNumber;
	GolfMemoirAppDelegate *deleg;
}

- (id)init:(NSInteger) playerNo;

@end
