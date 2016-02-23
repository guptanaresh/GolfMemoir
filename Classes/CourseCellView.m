/*
 Stroke
 */
#import "CourseCellView.h"

@implementation CourseCellView

@synthesize mCourse;
@synthesize row;


- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		self.opaque = YES;
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}




- (void)dealloc {
    [super dealloc];
}


@end
