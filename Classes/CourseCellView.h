

#import <UIKit/UIKit.h>
#import "Course.h"


@interface CourseCellView : UIView {
	Course *mCourse;
	NSUInteger					row;
}

@property (nonatomic, assign) Course *mCourse;
@property (nonatomic, assign) NSUInteger row;

@end
