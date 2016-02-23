//
//  MapLocationViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 7/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapLocationViewController.h"
#import "MapAnnotation.h"
#import "MapHoleAnnotation.h"
#import "Constants.h"
#import "MyMapAnnotationView.h"


@implementation MapLocationViewController
@synthesize mapView;
@synthesize deleg;
@synthesize locationManager;

- (id)init
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (GolfMemoirAppDelegate *)[app delegate];
		locationManager=[[CLLocationManager alloc] init];
		locationManager.delegate=self;
		locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
		formatter=[[NSNumberFormatter alloc] init];
	}
	return self;
}

/*
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
//	mapView=[[MKMapView alloc] initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, self.view.frame.size.height)];
	mapView=[[MKMapView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width/2, -self.view.frame.size.height/2, 2*self.view.frame.size.width, 2*self.view.frame.size.height)];
	mapView.showsUserLocation=TRUE;
	mapView.mapType=MKMapTypeSatellite;
	mapView.scrollEnabled = YES;
	mapView.zoomEnabled = YES;
	mapView.delegate=self;

	if(deleg.mScore.mCourse.curHole.latitude != 0.0 || deleg.mScore.mCourse.curHole.longitude != 0.0){
		CLLocationCoordinate2D  coror;
		coror.longitude=deleg.mScore.mCourse.curHole.longitude;
		coror.latitude=deleg.mScore.mCourse.curHole.latitude;
		MapHoleAnnotation *annotation = [[MapHoleAnnotation alloc] initWithCoordinate:coror user:mapView.userLocation.location hole:deleg.mScore.curHole.holeID holeType:YES];
		[mapView addAnnotation:annotation];
	}
	if(deleg.mScore.mCourse.curHole.teeLongitude != 0.0 || deleg.mScore.mCourse.curHole.teeLatitude != 0.0){
		CLLocationCoordinate2D  coror;
		coror.longitude=deleg.mScore.mCourse.curHole.teeLongitude;
		coror.latitude=deleg.mScore.mCourse.curHole.teeLatitude;
		MapHoleAnnotation *annotation = [[MapHoleAnnotation alloc] initWithCoordinate:coror user:mapView.userLocation.location hole:deleg.mScore.curHole.holeID holeType:NO];
		[mapView addAnnotation:annotation];
	}
	
   // viewTouch = [[MapOverlayView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height) withMap:mapView];
    viewTouch = [[MapOverlayView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width/2, -self.view.frame.size.height/2, 2*self.view.frame.size.width, 2*self.view.frame.size.height) withMap:mapView];
	
    [viewTouch addSubview:mapView];
    [self.view addSubview:mapView];
	
	
	[locationManager startUpdatingLocation];
	if([CLLocationManager headingAvailable]){
		locationManager.headingFilter = 5;
		[locationManager startUpdatingHeading];
	}

	NSArray *segmentTextContent = [NSArray arrayWithObjects:@"Drop Pin", @"OK", 
								   nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.backgroundColor=[UIColor clearColor];
	
	[segmentedControl addTarget:self action:@selector(mainAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 120, kCustomButtonHeight);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
	
	NSArray *scoresegmentTextContent = [NSArray arrayWithObjects:@"Drive", @"FWay",@"Putt", @"",[UIImage imageNamed:@"up.png"],nil];
	UISegmentedControl *leftsegmentedControl = [[UISegmentedControl alloc] initWithItems:scoresegmentTextContent];
	leftsegmentedControl.backgroundColor=[UIColor clearColor];
	
	[leftsegmentedControl addTarget:self action:@selector(myScoreControlAction:) forControlEvents:UIControlEventValueChanged];
	leftsegmentedControl.frame = CGRectMake(0, 0, 240, kCustomButtonHeight);
	leftsegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	leftsegmentedControl.momentary = YES;
	[leftsegmentedControl setTitle:[NSString stringWithFormat:@"%i", deleg.mScore.curHole.strokeNum] forSegmentAtIndex:3];
	[leftsegmentedControl setEnabled:FALSE forSegmentAtIndex:3];
	[leftsegmentedControl setImage:[UIImage imageNamed:@"segment_check.png"]  forSegmentAtIndex:deleg.mScore.curHole.putt];

	UIBarButtonItem *leftsegmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftsegmentedControl];
	self.navigationItem.leftBarButtonItem = leftsegmentBarItem;

	
	UIAlertView *vi = [[UIAlertView alloc] initWithTitle:@"Range Finder" message:@"Drag the map until you see the hole. Then click the 'Drop Pin' button to find distance to any point on the course."
												delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[vi show];
	[vi release];
	
}

-(CLLocationDistance) getDistance:(CLLocation *) newLocation
{
	CLLocationDistance dist=0;
	if(newLocation !=nil && (deleg.mScore.mCourse.curHole.longitude != 0.0 || deleg.mScore.mCourse.curHole.latitude != 0.0)){
		CLLocation *holeLoc = [[CLLocation alloc] initWithLatitude:deleg.mScore.mCourse.curHole.latitude longitude:deleg.mScore.mCourse.curHole.longitude ] ;
		dist= [newLocation distanceFromLocation:holeLoc] ;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if(![defaults boolForKey:MY_DISTANCE_PREF_KEY])
			dist = dist * kMeterToYardConversion;
		[holeLoc release];
	}
	return dist;
}

- (void)myScoreControlAction:(id)sender
{
	UISegmentedControl *csender = (UISegmentedControl *)sender;
	if(csender.selectedSegmentIndex == 4){
		deleg.mScore.curHole.strokeNum  = [[formatter numberFromString:[csender titleForSegmentAtIndex:3]] integerValue];
		deleg.mScore.curHole.strokeNum +=1;
		//deleg.mScore.curHole.putt = myPuttControlView.selectedSegmentIndex;
		CLLocation *newLoc = mapView.userLocation.location;
		if([mapView isUserLocationVisible] && newLoc !=nil){
			deleg.mScore.curHole.longitude = newLoc.coordinate.longitude;
			deleg.mScore.curHole.latitude = newLoc.coordinate.latitude;
			deleg.mScore.curHole.distance = [NSNumber numberWithDouble:[self getDistance:newLoc]].integerValue;
			
		}
		[deleg.mScore.curHole toDB];
		[deleg.mScore.curHole saveStroke];
		
		[((UISegmentedControl *)sender) setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:deleg.mScore.curHole.strokeNum]] forSegmentAtIndex:3];
		[((UISegmentedControl *)sender) setEnabled:FALSE forSegmentAtIndex:3];
		//myScoreTotalView.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[deleg.mScore totalScore:1]]];
		
		// look ahead for next stroke
		deleg.mScore.curHole.strokeNum +=1;
		if([deleg.mScore.curHole readStroke]){
			//myPuttControlView.selectedSegmentIndex = deleg.mScore.curHole.putt;
		}
		//restore stroke data
		deleg.mScore.curHole.strokeNum -=1;
		
		
	}
	else if(csender.selectedSegmentIndex <= 2 ){
		deleg.mScore.curHole.putt = csender.selectedSegmentIndex;	
		[csender setTitle:@"Drive"  forSegmentAtIndex:0];
		[csender setTitle:@"FWay"  forSegmentAtIndex:1];
		[csender setTitle:@"Putt"  forSegmentAtIndex:2];
		[csender setImage:[UIImage imageNamed:@"segment_check.png"]  forSegmentAtIndex:csender.selectedSegmentIndex];
}
	
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	//if(newLocation !=nil){
	    if (!signbit(newLocation.horizontalAccuracy) /*&& (location.latitude != newLocation.coordinate.latitude) && (location.longitude != newLocation.coordinate.longitude)*/) {
			location=newLocation.coordinate;
			//One location is obtained.. just zoom to that location
			//0, -20, self.view.frame.size.width, self.view.frame.size.height;
			
			
			MKCoordinateRegion region;

			region.center=location;
			//Set Zoom level using Span
			MKCoordinateSpan span;
			span.latitudeDelta=kMapSpanLatitudeDelta; //5/1110
			span.longitudeDelta=kMapSpanLatitudeDelta;
			region.span=span;
			
			[mapView setRegion:region animated:FALSE];
			
			CGPoint st=[mapView convertCoordinate:mapView.centerCoordinate toPointToView:self.view];
			st.y -= kMapUserLocationOffset;
			[mapView setCenterCoordinate: [mapView convertPoint:st toCoordinateFromView:self.view] animated:FALSE];

			[locationManager stopUpdatingLocation];
		}
	//}
	
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	if (newHeading.headingAccuracy > 0)
	{
		CGAffineTransform trans=CGAffineTransformMakeRotation(-1 * (newHeading.magneticHeading) * 3.14159 / 180);
		CGAffineTransform transText=CGAffineTransformMakeRotation(-1 * (newHeading.magneticHeading) * 3.14159 / 180);
		[mapView setTransform:trans];	
		[viewTouch setTransform:trans];	
		NSArray *arr=mapView.annotations;
		for(int i=0; i<[arr count];i++){
			MKAnnotationView *vw=[mapView viewForAnnotation:[arr objectAtIndex:i]];
			if(vw){
				[vw setTransform:transText];	
			}
		}
		if(mapView.userLocation.updating){
			location=mapView.userLocation.location.coordinate;
			
			MKCoordinateRegion region;
			
			region.center=location;
			//Set Zoom level using Span
			MKCoordinateSpan span;
			span.latitudeDelta=kMapSpanLatitudeDelta; //5/1110
			span.longitudeDelta=kMapSpanLatitudeDelta;
			region.span=span;
			
			[mapView setRegion:region animated:FALSE];
			
			CGPoint st=[mapView convertCoordinate:mapView.centerCoordinate toPointToView:self.view];
			st.y -= kMapUserLocationOffset;
			[mapView setCenterCoordinate: [mapView convertPoint:st toCoordinateFromView:self.view] animated:FALSE];
		}
	}
}

- (void)mainAction:(id)sender
{
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		[self.view addSubview:viewTouch];
		UIAlertView *vi = [[UIAlertView alloc] initWithTitle:@"Range Finder" message:@"Click anywhere on the map to find distance from your current location."
													delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[vi show];
		[vi release];
	}
	/*
	else
		if(((UISegmentedControl *)sender).selectedSegmentIndex == 1){
			[self.view addSubview:viewTouch];
		}*/
		else
			[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}	

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[locationManager stopUpdatingLocation];
	if(locationManager.headingAvailable)
		[locationManager startUpdatingHeading];
}


- (void)dealloc {
	[formatter release];
    [super dealloc];
}


- (MKAnnotationView *)mapView:(MKMapView *)amapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView* annotationView;

	if (annotation == amapView.userLocation)
	{
		// We can return nil to let the MapView handle the default annotation view (blue dot):
		// return nil;
		
		// Or instead, we can create our own blue dot and even configure it:
		/*
		annotationView = [amapView dequeueReusableAnnotationViewWithIdentifier:@"blueDot"];
		if (annotationView != nil)
		{
			annotationView.annotation = annotation;
		}
		else
		{
			annotationView = [[[NSClassFromString(@"MKUserLocationView") alloc] initWithAnnotation:annotation reuseIdentifier:@"blueDot"] autorelease];
			
			// Optionally configure the MKUserLocationView object here
			// Google MKUserLocationView for the options
			
		}
		 */
		annotationView = nil;
	}
	else
	{
		// The requested annotation view is for another annotation than the userLocation.
		// Let's return a normal pin:
		
		NSString* identifier = @"regularPin";
		annotationView = [amapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if (annotationView != nil)
		{
			annotationView.annotation = annotation;
		}
		else
		{
			annotationView = [[[MyMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
			[annotationView setTransform:[amapView transform]];	
		}
	}
	return annotationView;
}
/*
- (void)mapView:(MKMapView *)amapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	NSLog(@"calloutAccessoryControlTapped");
	

}
*/


@end
