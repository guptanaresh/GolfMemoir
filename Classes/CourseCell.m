

#import "CourseCell.h"
#import "CourseCellView.h"


@implementation CourseCell

@synthesize courseCellView;
@synthesize mCourse;
@synthesize row;


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		
		CGRect tzvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		courseCellView = [[CourseCellView alloc] initWithFrame:tzvFrame];
		courseCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:courseCellView];
	}
	return self;
}


- (void)setMCourse:(Course *)aCourse {
	courseCellView.mCourse = aCourse;
	mCourse=aCourse;
}
- (void)setRow:(NSUInteger)rowNum {
	courseCellView.row = rowNum;
	row=rowNum;
}


- (void)dealloc {
	[courseCellView release];
    [super dealloc];
}


@end
