/*
 
 File: DataHandler.h
 Abstract: Concentrates the management of the messages related to the application specific protocol. It retrieves the data to send and store from the DataProvider.
		   This is and example of the protocol (4 first bytes = command):
 
		   Peer A -> SENDFoo bar
		   Peer B -> ACPT
		   Peer A -> SIZE8
		   Peer B -> ACKN
		   Peer A -> Beam It!
		   Peer B -> SUCS
 
		   Refer to DataHandler.m for more details.
 
 Version: 1.0
 */

#import "AudioToolbox/AudioToolbox.h"
#import "BTDevicesManager.h"

typedef enum
{
	DHSNone,
	DHSReceiving,
	DHSSending
} DataHandlerState;

@interface DataHandler : NSObject {
	DataHandlerState currentState;
	BTDevice *currentStateRelatedDevice;
	
	BTDevicesManager *devicesManager;

	UIAlertView *currentPopUpView;
		
}

- (id)initWithDeviceManager:(BTDevicesManager *)manager;
- (void)dataStored;
- (void) sendToDevice:(BTDevice *) dev;

@end