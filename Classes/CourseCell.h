
#import <UIKit/UIKit.h>
#import "Course.h"

@class CourseCellView;

@interface CourseCell : UITableViewCell {
	CourseCellView *courseCellView;
	Course *mCourse;
	NSUInteger					row;
}

@property (nonatomic, assign) Course *mCourse;
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, retain) CourseCellView *courseCellView;

@end
