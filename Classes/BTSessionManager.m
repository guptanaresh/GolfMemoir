/*
 
 File: BTSessionManager.m
 Abstract: Delegate for the session and sends notifications when it changes.
 Version: 1.0
 
*/

#import "BTSessionManager.h"
#import "GolfMemoirAppDelegate.h"
#import "User.h"

@interface BTSessionManager ()

- (BTDevice *)addDevice:(NSString *)peerID;
- (void)removeDevice:(BTDevice *)device;
- (NSDictionary *)getDeviceInfo:(BTDevice *)device;

@end


@implementation BTSessionManager

- (id)initWithDataHandler:(DataHandler *)handler devicesManager:(BTDevicesManager *)manager {
	self = [super init];
	
	if (self) {
		devicesManager = manager;
		UIApplication *app = [UIApplication sharedApplication];
		GolfMemoirAppDelegate *deleg = (GolfMemoirAppDelegate *)[app delegate];
		User *aUser=[[User alloc] initWithDB:deleg.database];
		beamItSession = [[GKSession alloc] initWithSessionID:GOLF_MEMOIR_GLOBAL_SESSION_ID displayName:aUser.userName sessionMode:GKSessionModePeer];
		beamItSession.delegate = self;
		[beamItSession setDataReceiveHandler:handler withContext:nil];
	}
	
	return self;
}

- (void)start {
	beamItSession.available = YES;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	BTDevice *currentDevice = [devicesManager deviceWithID:peerID];
	
	// Instead of trying to respond to the event directly, it delegates the events.
	// The availability is checked by the main ViewController.
	// The connection is verified by each BTDevice.
	switch (state) {
		case GKPeerStateConnected:
			if (currentDevice) {
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTED object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}
			break;
		case GKPeerStateConnecting:
		case GKPeerStateAvailable:
			if (!currentDevice) {
				currentDevice = [self addDevice:peerID];
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_AVAILABLE object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}
			break;
		case GKPeerStateUnavailable:
			if (currentDevice) {
				[currentDevice retain];
				[self removeDevice:currentDevice];
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_UNAVAILABLE object:nil userInfo:[self getDeviceInfo:currentDevice]];
				[currentDevice release];
			}
			break;
		case GKPeerStateDisconnected:
			if (currentDevice) {
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_DISCONNECTED object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}
			break;
	}
}

- (BTDevice *)addDevice:(NSString *)peerID {
	BTDevice *device = [[BTDevice alloc] initWithSession:beamItSession peer:peerID];
	[devicesManager addDevice:device];
	[device release];
	
	return device;
}

- (void)removeDevice:(BTDevice *)device {
	[devicesManager removeDevice:device];
}

- (NSDictionary *)getDeviceInfo:(BTDevice *)device {
	return [NSDictionary dictionaryWithObject:device forKey:DEVICE_KEY];
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	[beamItSession acceptConnectionFromPeer:peerID error:nil];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	BTDevice *currentDevice = [devicesManager deviceWithID:peerID];
	
	// Does the same thing as the didStateChange method. It tells a BTDevice that the connection failed.
	if (currentDevice) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTION_FAILED object:nil userInfo:[self getDeviceInfo:currentDevice]];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	exit(0);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"BLUETOOTH_ERROR_TITLE", @"Title for the error dialog.")
														message:NSLocalizedString(@"BLUETOOTH_ERROR", @"Wasn't able to make bluetooth available")
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	
	[errorView show];
	[errorView release];
}

- (BOOL)sendAllData:(NSData *)data error:(NSError **)error {
	return [beamItSession sendData:data toPeers:[devicesManager sortedDevices] withDataMode:GKSendDataReliable error:error];
}


@end
