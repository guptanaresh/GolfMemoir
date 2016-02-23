/*
 
 File: BTDevicesManager.h
 Abstract: Contains a list of devices.
 Version: 1.0
 
 */

#import "BTDevice.h"

@interface BTDevicesManager : NSObject {
	NSMutableArray *devices;
}

- (void)addDevice:(BTDevice *)device;
- (void)removeDevice:(BTDevice *)device;
- (BTDevice *)deviceWithID:(NSString *)peerID;

@property (nonatomic, readonly) NSArray *sortedDevices;

@end
