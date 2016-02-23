/*
 
 File: DeviceCell.m
 Abstract: A specific cell that stores a reference for a device.
 Version: 1.0
  */

#import "DeviceCell.h"

@implementation DeviceCell

@synthesize device;

- (void)setDevice:(BTDevice *)d {
	device = d;
	self.textLabel.text = device.deviceName;
	self.selectionStyle = UITableViewCellSelectionStyleGray;
	self.textLabel.textColor = [UIColor blackColor];
}

@end
