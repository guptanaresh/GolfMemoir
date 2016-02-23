/*
 
 File: BTSessionManager.h
 Abstract: Delegate for the session and sends notifications when it changes.
 Version: 1.0
*/

#import <GameKit/GameKit.h>
#import "DataHandler.h"
#import "BTDevicesManager.h"

#define GOLF_MEMOIR_GLOBAL_SESSION_ID @"golf_memoir"

#define NOTIFICATION_DEVICE_AVAILABLE @"notif_device_available"
#define NOTIFICATION_DEVICE_UNAVAILABLE @"notif_device_unavailable"
#define NOTIFICATION_DEVICE_CONNECTED @"notif_device_connected"
#define NOTIFICATION_DEVICE_CONNECTION_FAILED @"notif_device_connection_failed"
#define NOTIFICATION_DEVICE_DISCONNECTED @"notif_device_disconnected"

#define DEVICE_KEY @"BTDevice"

@interface BTSessionManager : NSObject<GKSessionDelegate> {
	GKSession *beamItSession;
	BTDevicesManager *devicesManager;
}

- (id)initWithDataHandler:(DataHandler *)handler devicesManager:(BTDevicesManager *)manager;
- (void)start;
- (BOOL)sendAllData:(NSData *)data error:(NSError **)error;

@end
