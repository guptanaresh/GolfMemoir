//
//  CourseTable.m
//  GolfMemoir
//
//  Created by naresh gupta on 6/8/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import "CourseTable.h"


@implementation CourseTable

@synthesize mCourse;




-(id)initWithCourse:(Course *)aCourse textFieldResign:(UITextField *)myField
{
	self = [super init];
	mCourse = aCourse;
	mCurrentTextField=nil;
	mExtCurrentTextField=myField;
	return self;
}



- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return 18;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section    // fixed font style. use custom view (UILabel) if you want something different
{
	return @"Hole       Par           Yards    Location";
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
	NSMutableString *aNameStr = [NSMutableString alloc];
	aNameStr = [aNameStr initWithString:[formatter stringFromNumber:[NSNumber numberWithInteger:indexPath.row+1]]];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:aNameStr];
	
	if (cell == nil) {
		cell = [self tableviewCellWithReuseIdentifier:aNameStr line:indexPath.row+1];
	}
	
	[formatter release];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self resignKeyboard];
}

- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier line:(NSInteger)row{
		
		/*
		 Create an instance of UITableViewCell and add tagged subviews for the name, local time, and quarter image of the time zone.
		 */
	NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
	NSMutableString *aNameStr = [NSMutableString alloc];
	aNameStr = [aNameStr initWithString:@"   "];
	[aNameStr appendString:[formatter stringFromNumber:[NSNumber numberWithInteger: row]]];
	//[aNameStr appendString:@":"];
	CGRect rect;
		
		rect = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
		
		UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
/*		
		UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"CourseCell" owner:self options:nil] lastObject ];
		[cell.contentView addSubview:cView];
*/
		
		/*
		 Create labels for the text fields; set the highlight color so that when the cell is selected it changes appropriately.
		 */
		UILabel *label;
		
		rect = CGRectMake(LEFT_COLUMN_OFFSET, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, LEFT_COLUMN_WIDTH, LABEL_HEIGHT);
		label = [[UILabel alloc] initWithFrame:rect];
		label.tag = HOLE_TAG;
		label.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
		label.adjustsFontSizeToFitWidth = YES;
		label.text=aNameStr;
		[cell.contentView addSubview:label];
		label.highlightedTextColor = [UIColor whiteColor];
		[label release];
		
	NSArray *segmentTextContent = [NSArray arrayWithObjects: [UIImage imageNamed:@"down.png" ],
								   [UIImage imageNamed:@"blank.png" ],
								   [UIImage imageNamed:@"up.png"],
								   nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.backgroundColor=[UIColor clearColor];
	
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(MIDDLE_COLUMN_OFFSET, (cell.frame.size.height -  ROW_HEIGHT) / 2.0, MIDDLE_COLUMN_WIDTH, ROW_HEIGHT);
	segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedControl.momentary = YES;
	segmentedControl.tag = row;
	mCourse.holeNumber = row;
	[segmentedControl setTitle:[formatter stringFromNumber:[NSNumber numberWithInteger:mCourse.curHole.whitePar]] forSegmentAtIndex:1];
	[cell.contentView addSubview:segmentedControl];
	
		// Create an image view for the quarter image
		
	
	rect = CGRectMake(RIGHT_COLUMN_OFFSET, (cell.frame.size.height - LABEL_HEIGHT) / 2.0, RIGHT_COLUMN_WIDTH, LABEL_HEIGHT);
	
	UITextField *textView = [[UITextField alloc] initWithFrame:rect];
	textView.tag = row;
	textView.clearsOnBeginEditing = TRUE;
	textView.borderStyle = UITextBorderStyleBezel;
	textView.textColor = [UIColor blackColor];
	textView.font = [UIFont systemFontOfSize:17.0];
	//textView.placeholder = @"<enter text>";
	textView.backgroundColor = [UIColor whiteColor];
	textView.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	textView.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the default type input method (entire keyboard)
	textView.returnKeyType = UIReturnKeyDone;
	textView.delegate=self;
	textView.text=[formatter stringFromNumber:[NSNumber numberWithInteger:mCourse.curHole.whiteYard]];
	
	[cell.contentView addSubview:textView];
	[textView release];
	
	rect= CGRectMake(FOURTH_COLUMN_OFFSET, (cell.frame.size.height -  ROW_HEIGHT) / 2.0, FOURTH_COLUMN_WIDTH, ROW_HEIGHT);
	
	UIButton *roundedButtonType = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	roundedButtonType.frame = rect;
	roundedButtonType.tag = row;
	[roundedButtonType setTitle:@"Set" forState:UIControlStateNormal];
	roundedButtonType.backgroundColor = [UIColor clearColor];
	[roundedButtonType addTarget:self action:@selector(setLocationAction:) forControlEvents:UIControlEventTouchUpInside];

	[cell.contentView addSubview:roundedButtonType];
	[roundedButtonType release];
	
	[formatter release];
		return cell;
	}
	
- (void)segmentAction:(id)sender
{
	[self resignKeyboard];
	NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
	NSString *str;
	NSInteger par;
	str = [((UISegmentedControl *)sender) titleForSegmentAtIndex:1];
	par = [[formatter numberFromString:str] integerValue];
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		if(par >1)
		par -=1;
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 2){
		par +=1;
	}
	str = [formatter stringFromNumber:[NSNumber numberWithInteger:par]] ;
	[((UISegmentedControl *)sender) setTitle:str forSegmentAtIndex:1];
	
	NSInteger hole = ((UISegmentedControl *)sender).tag;
	mCourse.holeNumber=hole;
	mCourse.curHole.whitePar = par;
	[mCourse.curHole toDB];
	[formatter release];
	
}

- (void)setLocationAction:(id)sender
{
	[self resignKeyboard];
	NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
	NSString *str;
	NSInteger par;
	str = [((UISegmentedControl *)sender) titleForSegmentAtIndex:1];
	par = [[formatter numberFromString:str] integerValue];
	if(((UISegmentedControl *)sender).selectedSegmentIndex == 0){
		if(par >1)
			par -=1;
	}
	else if(((UISegmentedControl *)sender).selectedSegmentIndex == 2){
		par +=1;
	}
	str = [formatter stringFromNumber:[NSNumber numberWithInteger:par]] ;
	[((UISegmentedControl *)sender) setTitle:str forSegmentAtIndex:1];
	
	NSInteger hole = ((UISegmentedControl *)sender).tag;
	mCourse.holeNumber=hole;
	mCourse.curHole.whitePar = par;
	[mCourse.curHole toDB];
	[formatter release];
	
}


- (void)textFieldDidEndEditing:(UITextField *)textField            // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
	NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
	NSInteger yard;
	yard = [[formatter numberFromString:textField.text] integerValue];
	NSInteger hole = textField.tag;
	mCourse.holeNumber=hole;
	mCourse.curHole.whiteYard = yard;
	[mCourse.curHole toDB];
	if([textField isFirstResponder])
		[textField resignFirstResponder];
	
	[formatter release];

}
- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{
	mCurrentTextField=textField;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
{
	return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
	[textField resignFirstResponder];
	return TRUE;
}

-(void) resignKeyboard
{
	if(mCurrentTextField != nil)
		[mCurrentTextField resignFirstResponder];
	if(mExtCurrentTextField != nil)
		[mExtCurrentTextField resignFirstResponder];

	
}

- (void)dealloc {
	[super dealloc];
}


@end
