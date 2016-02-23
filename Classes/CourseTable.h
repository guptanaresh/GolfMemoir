//
//  ScoreTable.h
//  GolfMemoir
//
//  Created by naresh gupta on 6/8/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"

#define HOLE_TAG 1
#define PAR_TAG 2
#define YARD_TAG 3
#define LEFT_COLUMN_OFFSET 0.0
#define LEFT_COLUMN_WIDTH 50.0

#define MIDDLE_COLUMN_OFFSET 40.0
#define MIDDLE_COLUMN_WIDTH 120.0

#define RIGHT_COLUMN_OFFSET 172.0
#define RIGHT_COLUMN_WIDTH 50

#define FOURTH_COLUMN_OFFSET 232.0
#define FOURTH_COLUMN_WIDTH 80

#define MAIN_FONT_SIZE 18.0
#define LABEL_HEIGHT 28.0
#define ROW_HEIGHT 35

@interface CourseTable : NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	Course *mCourse;
	CGRect	frm;
	UITextField	*mCurrentTextField;
	UITextField	*mExtCurrentTextField;
}

@property (nonatomic, assign) Course *mCourse;

- (id)initWithCourse:(Course *)aCourse textFieldResign:(UITextField *)myField;
- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier line:(NSInteger)row;
-(void) resignKeyboard;
@end
