//
//  MapLocationViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 7/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>
#import <CoreLocation/CoreLocation.h>
#import "MapOverlayView.h"
#import "GolfMemoirAppDelegate.h"

@interface MapLocationViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
	MKMapView *mapView;
	MapOverlayView *viewTouch;
	CLLocationCoordinate2D location;
	CLLocationManager *locationManager;
	GolfMemoirAppDelegate *deleg;
	NSNumberFormatter *formatter;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, assign) GolfMemoirAppDelegate *deleg;
@property (nonatomic, assign) CLLocationManager *locationManager;

@end
