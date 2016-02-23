//
//  HolePickerView.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/10/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomPicker;


@interface HolePickerView : UIPickerView <UIPickerViewDelegate>
{
	NSArray				*holePickerArray;
}
- (id)initWithFrame:(CGRect)rect andData:(NSArray *) pickArray;

@end
