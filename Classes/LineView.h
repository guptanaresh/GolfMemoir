//
//  LineView.h
//  GolfMemoir
//
//  Created by naresh gupta on 4/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LineView : UIView {
	CGPoint coord;
	CGPoint usercoord;

}

-(id)initWithPt:(CGPoint)coor start:(CGPoint) usercoor;

@property (nonatomic, assign) CGPoint coord;
@property (nonatomic, assign) CGPoint usercoord;

@end
