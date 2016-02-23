//
//  MapAnnotation.h
//  GolfMemoir
//
//  Created by naresh gupta on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D _coordinate;
	CLLocation *userloc;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate user:(CLLocation *)location;
- (NSString *)title;
- (NSString *)subtitle;

//@property (nonatomic, assign) CLLocationCoordinate2D _coordinate;
//@property (nonatomic, assign) CLLocation *userloc;

@end
