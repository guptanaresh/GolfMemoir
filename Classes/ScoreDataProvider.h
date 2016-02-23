/*
 */

#import <AddressBookUI/AddressBookUI.h>
#import "DataProvider.h"
#import "PeerViewController.h"

@interface ScoreDataProvider : NSObject<DataProvider> {
	id delegateToCall;
	SEL selectorToCall;
	
	UIViewController *mainViewController;
	GolfMemoirAppDelegate *deleg;
}

- (id)initWithMainViewController:(PeerViewController *)viewController;

@end
