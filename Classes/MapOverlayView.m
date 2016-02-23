//
//  MapOverlayView.m
//  GolfMemoir
//
//  Created by naresh gupta on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapOverlayView.h"
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"
#import "LineView.h"

@implementation MapOverlayView
@synthesize viewTouched;

- (id)initWithFrame:(CGRect)frame withMap:(MKMapView *)map;
{
	if (self = [super initWithFrame:frame]) {
		viewTouched=map;
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"Hit Test");
    //viewTouched = [super hitTest:point withEvent:event];
    return self;
}

//Then, when an event is fired, we log this one and then send it back to the viewTouched we kept, and voilà!!! :)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Began");
   // [viewTouched touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Moved");
  // [viewTouched touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Ended");
    //[viewTouched touchesEnded:touches withEvent:event];
    for (UITouch *touch in touches) {
        // Send to the dispatch method, which will make sure the appropriate subview is acted upon
		MapAnnotation *annotation = nil;
		annotation = [[MapAnnotation alloc] initWithCoordinate:[viewTouched convertPoint:[touch locationInView:self] toCoordinateFromView:viewTouched ] user:viewTouched.userLocation.location];
		[viewTouched addAnnotation:annotation];
		//LineView *vw=[[LineView alloc] initWithPt:[viewTouched convertCoordinate:viewTouched.userLocation.location.coordinate  toPointToView:self ] start:[touch locationInView:self]];
		//[self addSubview:vw];
    }    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Cancelled");
   // [viewTouched touchesCancelled:touches withEvent:event];
}

@end
