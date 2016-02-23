//
//  MyMapAnnotationView.m
//  GolfMemoir
//
//  Created by naresh gupta on 7/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyMapAnnotationView.h"
#import "MapAnnotation.h"

#define kHeight 20
#define kWidth  200
#define kBorder 2

@implementation MyMapAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	self.frame = CGRectMake(0, 0, kWidth, kHeight);
	self.animatesDrop=TRUE;
	UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(kBorder, kBorder, kWidth - 2 * kBorder, kHeight - 2 * kBorder)];
	lbl.text=[annotation title];
	lbl.opaque=FALSE;
	lbl.backgroundColor=[UIColor clearColor];
	lbl.textColor=[UIColor whiteColor];
	lbl.shadowColor=[UIColor redColor];
	lbl.textAlignment=NSTextAlignmentLeft;
	lbl.font=[UIFont boldSystemFontOfSize:24.0];
	[self addSubview:lbl];
		return self;
	
}

-(void) dealloc
{
	[super dealloc];
}


@end
