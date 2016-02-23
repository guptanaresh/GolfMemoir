/*
 
 File: ScoreDataProvider.m
 Abstract: Implementation of the DataProvider specifically for beaming contacts.
 Version: 1.0
 
 */

#import "ScoreDataProvider.h"

@implementation ScoreDataProvider

- (id)initWithMainViewController:(PeerViewController *)viewController {
	self = [super init];
	
	if (self) {
		mainViewController = viewController;
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
	}
	
	return self;
}

- (void)prepareDataAndReplyTo:(id)delegate selector:(SEL)dataPreparedSelector {
	delegateToCall = delegate;
	selectorToCall = dataPreparedSelector;
	if (delegateToCall && [delegateToCall respondsToSelector:selectorToCall])
		[delegateToCall performSelector:selectorToCall];
	
}


- (NSString *)getLabelOfDataToSend {
	return @"score";
}

- (NSData *)getDataToSend {
	NSString *str=[deleg.mScore toString:deleg.mScore.courseID];
	NSLog(str);
	return [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
}

- (BOOL)storeData:(NSData*)data andReplyTo:(id)delegate selector:(SEL)selector {
	NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSLog(str);
	return TRUE;
}


@end
