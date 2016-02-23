//
//  AsyncConnection.m
//  GolfMemoir
//
//  Created by naresh gupta on 12/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AsyncConnection.h"


@implementation AsyncConnection


- (id)init
{
    if (self = [super init])
    {
        _isConnected = false;
        _isFinished     = false;
    }
    return self;
}


-(void) connect
{
	{
		
		url = [NSURL URLWithString: @"http://www.google.com" ];  
		
		theRequest=[NSURLRequest requestWithURL : url
									cachePolicy : NSURLRequestReloadIgnoringCacheData
								timeoutInterval : 60.0];
		
		// create the connection with the request
		// and start loading the data
		theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		
		if (theConnection)
		{
			// Create the NSMutableData that will hold
			// the received data
			// receivedData is declared as a method instance elsewhere
			receivedData=[[NSMutableData data] retain];
			_isConnected = true;
		}
		else
		{
			// inform the user that the download could not be made
			_isConnected = false;
		}
	}
}


- (bool) isConnected
{
	return _isConnected;
}


- (NSError*) getError
{
	return theError;
}


- (bool) isFinished
{
	return _isFinished;
}


- (unsigned char*) getData
{
	int urlLength = [receivedData length];
	unsigned char *downloadBuffer;
	
	downloadBuffer = (unsigned char*) malloc (urlLength);
	
	[receivedData getBytes: (unsigned char*)downloadBuffer];
	
	return downloadBuffer;
}


- (int) getDataSize
{   
	return [receivedData length];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{ 
	// this method is called when the server has determined that it 
	// has enough information to create the NSURLResponse 
	// it can be called multiple times, for example in the case of a 
	// redirect, so each time we reset the data. 
	// receivedData is declared as a method instance elsewhere 
	[receivedData setLength:0]; 
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{ 
	// append the new data to the receivedData 
	// receivedData is declared as a method instance elsewhere 
	[receivedData appendData:data]; 
} 


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{ 
	// release the connection, and the data object
	[connection release]; 
	// receivedData is declared as a method instance elsewhere 
	[receivedData release]; 
	// inform the user 
	NSLog(@"Connection failed! Error - %@ %@", 
		  [error localizedDescription], 
		  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]); 
} 


- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{ 
	// do something with the data 
	// receivedData is declared as a method instance elsewhere 
	NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]); 
	// release the connection, and the data object 
	
	_isFinished = true;
	
}

- (void) dealloc
{
	
    [super dealloc];
}

@end
