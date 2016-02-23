/*
 
 File: DeviceCell.h
 Abstract: A specific cell that stores a reference for a device.
 Version: 1.0
  */

#import "BTDevice.h"

@interface DeviceCell : UITableViewCell {
	BTDevice *device;
}

@property (nonatomic, retain) BTDevice *device;

@end
