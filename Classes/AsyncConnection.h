//
//  AsyncConnection.h
//  GolfMemoir
//
//  Created by naresh gupta on 12/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AsyncConnection : NSObject {
        NSMutableData   *receivedData;
        NSURL                   *url;
        NSURLRequest    *theRequest;
        NSURLConnection *theConnection;
        NSError                 *theError;
		
        bool                    _isConnected;
        bool                    _isFinished;
		
        id                              _delegate;
	}
	
	
	- (void) connect;
	- (bool) isConnected;
	- (bool) isFinished;
	- (NSError*) getError;
	- (int) getDataSize;
	
	- (unsigned char*) getData;
	
@end