//
//  HolePickerView.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/10/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import "HolePickerView.h"


@implementation HolePickerView
#define kPickerSegmentControlHeight 30.0


- (id)initWithFrame:(CGRect)rect andData:(NSArray *) pickArray
{
	self = [super initWithFrame:rect];
	if (self)
	{
		holePickerArray = pickArray;
		
		// assign ourselves as the delegate here since we know how to populate the picker's contents
		self.delegate = self;
	}
	return self;
}
- (id)initWithData:(NSArray *) pickArray
{
	self = [super init];
	if (self)
	{
		holePickerArray = pickArray;
		
		// assign ourselves as the delegate here since we know how to populate the picker's contents
		self.delegate = self;
	}
	return self;
}

- (void)dealloc
{
	[holePickerArray release];
	[super dealloc];
}


#pragma mark UIPicker delegate methods


// tell the picker which view to use for a given component and row, we have an array of color views to show
/*
 - (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
		  forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UIView *viewToUse = nil;
	if (component == 0)
	{
		viewToUse = [[colorViews pickerColors] objectAtIndex:row];
	}
	return viewToUse;
}
*/
// tell the picker how many components it will have (in our case we have one component)
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [holePickerArray count];
}

// tell the picker the title for a given component (in our case we have one component)
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *title;
	if (component == 0)
	{
			title = [holePickerArray objectAtIndex:row];
	}
	else{
		title = [holePickerArray objectAtIndex:row];
	}
	return title;
}

// tell the picker the width of each row for a given component (in our case we have one component)
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 40.0;
}
/*
- (CGSize)pickerView:(UIPickerView *)pickerView rowSizeForComponent:(NSInteger)component
{
	CGSize sz=CGSizeMake(50,50);
	return sz; 
}
*/

// tell the picker the height of each row for a given component (in our case we have one component)
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	
}

@end
