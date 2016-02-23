//
//  LineView.m
//  GolfMemoir
//
//  Created by naresh gupta on 4/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LineView.h"


@implementation LineView

@synthesize coord, usercoord;

-(id)initWithPt:(CGPoint)coor start:(CGPoint) usercoor
{
    if (self = [super init]) {
		coord=coor;
		usercoord=usercoor;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
		CGContextRef c = UIGraphicsGetCurrentContext();
		
		CGFloat red[4] = {1.0f, 1.0f,1.0f, 1.0f};
		CGContextSetStrokeColor(c, red);
		CGContextSetLineWidth(c, 2.0);
	
		CGContextBeginPath(c);
		CGContextMoveToPoint(c,coord.x, coord.y);
		CGContextAddLineToPoint(c, usercoord.x, usercoord.y);
		CGContextStrokePath(c);
}


- (void)dealloc {
    [super dealloc];
}


@end
