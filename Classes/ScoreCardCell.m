

#import "ScoreCardCell.h"
#import "ScoreCardCellView.h"


@implementation ScoreCardCell

@synthesize scoreCellView;
@synthesize mScore;
@synthesize row, section;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		
		CGRect tzvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		scoreCellView = [[ScoreCardCellView alloc] initWithFrame:tzvFrame];
		scoreCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:scoreCellView];
	}
	return self;
}


- (void)setMScore:(Score *)aScore {
	scoreCellView.mScore = aScore;
	mScore=aScore;
}
- (void)setRow:(NSUInteger)rowNum {
	scoreCellView.row = rowNum;
	row=rowNum;
}
- (void)setSection:(NSUInteger)rowNum {
	scoreCellView.section = rowNum;
	section=rowNum;
}


- (void)dealloc {
	[scoreCellView release];
    [super dealloc];
}


@end
