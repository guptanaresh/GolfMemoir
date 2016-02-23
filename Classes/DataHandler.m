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

#import "DataHandler.h"
#import "GolfMemoirAppDelegate.h"


#define PROCESSING_TAG 0
#define CONFIRMATION_RETRY_TAG 1
#define CONFIRMATION_RECEIVE_TAG 2

#define ERROR_SOUND_FILE_NAME "error"
#define RECEIVED_SOUND_FILE_NAME "received"
#define REQUEST_SOUND_FILE_NAME "request"
#define SEND_SOUND_FILE_NAME "sent"

@interface DataHandler ()


- (NSData *)dataFromString:(NSString *)str;


- (void)handleReceivingData:(NSData *)data;
- (void)handleSendingData:(NSData *)data;


- (void)throwError:(NSString *)message;
- (void)cleanCurrentState;
- (void)closeCurrentPopup;

//- (void)updateLastCommandReceived:(NSString *)command;

- (void)showMessageWithTitle:(NSString *)title message:(NSString *)msg;
- (void)promptConfirmationWithTag:(int)tag title:(NSString *)title message:(NSString *)msg;
- (void)showProcess:(NSString *)message;

//- (void)deviceConnected;

@end

@implementation DataHandler

- (id)initWithDeviceManager:(BTDevicesManager *)manager {
	self = [super init];
	
	if (self) {
		currentState = DHSNone;
		
		
		devicesManager = manager;
	}
	
	
	return self;
}


- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	// Caller whenever data is received from the session
	
	BTDevice *device = [devicesManager deviceWithID:peer];
	
	if (device) {
		// Checks if it's busy, otherwise call other handler methods
		switch (currentState) {
			case DHSNone:
				currentState = DHSReceiving;
				currentStateRelatedDevice = device;
				
				[self handleReceivingData:data];
				break;
			case DHSReceiving:
					[self handleReceivingData:data];
				break;
			case DHSSending:
					[self handleSendingData:data];
				break;
			default:
				break;
		}
	}
}


- (void)handleReceivingData:(NSData *)data {

				[self promptConfirmationWithTag:CONFIRMATION_RECEIVE_TAG 
										  title:NSLocalizedString(@"RECEIVE_VIEW_TITLE", @"Dialog title when receiving data")
										message:[NSString stringWithFormat:NSLocalizedString(@"RECEIVE_VIEW_PROMPT", @"Dialog text when receiving data"),
												 currentStateRelatedDevice.deviceName]];
				[self storeData:data];
}


- (BOOL)storeData:(NSData*)data{
	NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSLog(@"%@", str);
	return TRUE;
}


- (void)handleSendingData:(NSData *)data {
		[currentStateRelatedDevice sendData:[self getDataToSend] error:nil];
}

- (NSData *)getDataToSend {
	UIApplication *app = [UIApplication sharedApplication];
	GolfMemoirAppDelegate *deleg = (GolfMemoirAppDelegate *)[app delegate];
	NSString *str=[deleg.mScore toString:deleg.mScore.courseID];
	NSLog(@"%@", str);
	return [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == CONFIRMATION_RECEIVE_TAG) {
		if (buttonIndex == 1) { // YES
			[self closeCurrentPopup];
		} else { // NO
			[self closeCurrentPopup];
		}
	} else if (alertView.tag == CONFIRMATION_RETRY_TAG) {
		if (buttonIndex == 1) { // YES
			[self closeCurrentPopup];
		} else { // NO
		}
	} else if (alertView.tag == PROCESSING_TAG) {
		// Clicked on CANCEL
		
		[self closeCurrentPopup];

	}
}

- (NSData *)dataFromString:(NSString *)str {
	return [str dataUsingEncoding:NSUTF8StringEncoding];
}



- (void)deviceConnectionFailed {
	[self throwError:[NSString stringWithFormat:NSLocalizedString(@"CONNECTION_ERROR", "Error when connecting to peer"), 
					  currentStateRelatedDevice.deviceName]];
}


- (void)showMessageWithTitle:(NSString *)title message:(NSString *)msg {
	[self closeCurrentPopup];

	UIAlertView *confirmationView = [[UIAlertView alloc] initWithTitle:title
															   message:msg
															  delegate:nil
													 cancelButtonTitle:@"OK"
													 otherButtonTitles:nil];
	
	[confirmationView show];
	[confirmationView release];
}

- (void)throwError:(NSString *)message {
	[self showMessageWithTitle:NSLocalizedString(@"ERROR_VIEW_TITLE", @"Error dialog title") message:message];
	[self cleanCurrentState];
}

- (void)cleanCurrentState {
	currentState = DHSNone;
	
	if (currentStateRelatedDevice) {
		currentStateRelatedDevice = nil;
	}
	
	[self closeCurrentPopup];
}

- (void)closeCurrentPopup {
	if (currentPopUpView) {
		currentPopUpView.delegate = nil;
		[currentPopUpView dismissWithClickedButtonIndex:0 animated:YES];
		[currentPopUpView release];
		currentPopUpView = nil;
	}
}

- (void)promptConfirmationWithTag:(int)tag title:(NSString *)title message:(NSString *)msg {
	[self closeCurrentPopup];
	
	currentPopUpView = [[UIAlertView alloc] initWithTitle:title
												  message:msg
												 delegate:self
										cancelButtonTitle:@"No"
										otherButtonTitles:@"Yes", nil];
	currentPopUpView.tag = tag;
	
	[currentPopUpView show];
}

- (void)showProcess:(NSString *)message {
	[self closeCurrentPopup];
	
	currentPopUpView = [[UIAlertView alloc] initWithTitle:message
												  message:@"\n\n"
												 delegate:self
										cancelButtonTitle:@"Cancel"
										otherButtonTitles:nil];
	
	currentPopUpView.tag = PROCESSING_TAG;

	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
											 initWithFrame:CGRectMake(130, 60, 20, 20)];
	[activityView startAnimating];
	[currentPopUpView addSubview:activityView];
	[activityView release];
	
	[currentPopUpView show];
}

- (void)dealloc {
	
    [super dealloc];
}

@end
