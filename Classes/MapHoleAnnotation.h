//
//  MapAnnotation.h
//  GolfMemoir
//
//  Created by naresh gupta on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapHoleAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D _coordinate;
	CLLocation *userloc;
	NSInteger hole;
	BOOL		holeType;
}

@property (nonatomic, assign) NSInteger hole;
@property (nonatomic, assign) BOOL holeType;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate user:(CLLocation *)location  hole:(NSInteger)num holeType:(BOOL)ty;
- (NSString *)title;
- (NSString *)subtitle;


@end
