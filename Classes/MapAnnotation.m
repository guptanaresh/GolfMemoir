//
//  MapAnnotation.m
//  GolfMemoir
//
//  Created by naresh gupta on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapAnnotation.h"
#import "Constants.h"

@implementation MapAnnotation

@synthesize coordinate=_coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate user:(CLLocation *)location
{
	self = [super init];
	_coordinate = coordinate;
	userloc=location;
	return self;
}

- (NSString *)title
{
	CLLocation *loc=	[[CLLocation alloc] initWithCoordinate:_coordinate
												   altitude:userloc.altitude
										 horizontalAccuracy:userloc.horizontalAccuracy
										   verticalAccuracy:userloc.verticalAccuracy
												  timestamp:[[NSDate alloc] init]];
	
	return [NSString stringWithFormat:@"%3.1f", kMeterToYardConversion * [userloc distanceFromLocation:loc]];
}

- (NSString *)subtitle
{
	return [self title];
}


-(void) dealloc
{
	[super dealloc];
}

@end
