//
//  MapOverlayView.h
//  GolfMemoir
//
//  Created by naresh gupta on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIView;
@class MKMapView;

@interface MapOverlayView : UIView {
    MKMapView *viewTouched;
}
@property (nonatomic, retain) MKMapView *viewTouched;

- (id)initWithFrame:(CGRect)frame withMap:(MKMapView *)map;
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
