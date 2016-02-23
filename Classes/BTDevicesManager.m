/*
 
 File: BTDevicesManager.m
 Abstract: Contains a list of devices.
 Version: 1.0
 */

#import "BTDevicesManager.h"

@implementation BTDevicesManager

- (id)init {
	self = [super init];
	
	if (self)
		devices = [[NSMutableArray alloc] init];

	return self;
}

- (NSArray *)sortedDevices {
	return devices;
}

- (void)addDevice:(BTDevice *)device {
	[devices addObject:device];

	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deviceName" ascending:YES];
	[devices sortUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
	[nameDescriptor release];
}

- (void)removeDevice:(BTDevice *)device {
	if (device) {
		[devices removeObject:device];
	}
}

- (BTDevice *)deviceWithID:(NSString *)peerID {
	for (BTDevice *d in devices) {
		if ([d.peerID isEqual:peerID]) {
			return d;
		}
	}
	
	return nil;
}


- (void)dealloc {
	[devices release];
	[super dealloc];
}

@end
