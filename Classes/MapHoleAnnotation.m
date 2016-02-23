//
//  MapAnnotation.m
//  GolfMemoir
//
//  Created by naresh gupta on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapHoleAnnotation.h"
#import "Constants.h"

@implementation MapHoleAnnotation

@synthesize coordinate=_coordinate;
@synthesize hole, holeType;
-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate user:(CLLocation *)location  hole:(NSInteger)num holeType:(BOOL)ty
{
	self = [super init];
	_coordinate = coordinate;
	userloc=location;
	hole=num;
	holeType=ty;
	return self;
}

- (NSString *)title
{
	CLLocation *loc=	[[CLLocation alloc] initWithCoordinate:_coordinate
												   altitude:userloc.altitude
										 horizontalAccuracy:userloc.horizontalAccuracy
										   verticalAccuracy:userloc.verticalAccuracy
												  timestamp:[[NSDate alloc] init]];
	if(holeType == YES)
	return [NSString stringWithFormat:@"Hole %i (%3.1f)", hole, kMeterToYardConversion * [userloc distanceFromLocation:loc]];
	else
	return [NSString stringWithFormat:@"Tee %i (%3.1f)", hole, kMeterToYardConversion * [userloc distanceFromLocation:loc]];
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
