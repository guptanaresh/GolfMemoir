/*
 Stroke
 */
#import "ScoreCardCellView.h"

@implementation ScoreCardCellView

@synthesize mScore;
@synthesize row, section;


- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		self.opaque = YES;
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

/*
 - (void)drawRect:(CGRect)rect {
 #define LEFT_COLUMN_OFFSET 10
 #define LEFT_COLUMN_WIDTH 40
 
 #define MIDDLE_COLUMN_OFFSET 140
 #define MIDDLE_COLUMN_WIDTH 110
 
 #define RIGHT_COLUMN_OFFSET 270
 
 #define UPPER_ROW_TOP 8
 #define LOWER_ROW_TOP 34
 
 #define MAIN_FONT_SIZE 14
 #define MIN_MAIN_FONT_SIZE 12
 #define SECONDARY_FONT_SIZE 12
 #define MIN_SECONDARY_FONT_SIZE 10
 
 CGFloat	actualFontSize;
 CGSize	size;
 NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
 // Color and font for the main text items (time zone name, time)
 UIColor *mainTextColor = [UIColor blackColor];
 UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
 
 // Color and font for the secondary text items (GMT offset, day)
 UIColor *secondaryTextColor = [UIColor blueColor];
 UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
 
 
 CGRect contentRect = self.bounds;
 
 CGContextStrokeRect(UIGraphicsGetCurrentContext(), contentRect);
 int maxBox=11;
 CGFloat tenth = (contentRect.size.width) / (maxBox+2);
 int rows=2;
 Score *cScore = mScore;
 
 CGPoint pts[maxBox*rows];
 int start = 2;
 int startOffset = 0;
 if((mScore.gameType == kBackNineEnum) || ((mScore.gameType != kBackNineEnum) && row>0))
 startOffset+=9;
 int end=maxBox*rows;
 CGFloat startx= contentRect.origin.x + tenth+tenth;
 NSInteger saveHole = cScore.holeNumber;
 int iTotal = 0;
 int iTotalStbl = 0;
 for(int i=start; i<end;i+=rows, startx += tenth){
 //lines
 pts[i].x= startx;
 pts[i].y= contentRect.origin.y;
 pts[i+1].x= startx;
 pts[i+1].y= contentRect.origin.y+contentRect.size.height;
 
 if(i == end-rows){
 NSString *holeNumStr = [[NSString alloc] initWithString: @"Total"];
 size = [holeNumStr sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:MIDDLE_COLUMN_WIDTH lineBreakMode:NSLineBreakByTruncatingTail];
 [mainTextColor set];
 [holeNumStr drawAtPoint:pts[i] forWidth:LEFT_COLUMN_WIDTH withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
 
 
 holeNumStr = [formatter stringFromNumber:[NSNumber numberWithInteger:iTotal]];
 size = [holeNumStr sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:MIDDLE_COLUMN_WIDTH lineBreakMode:NSLineBreakByTruncatingTail];
 [secondaryTextColor set];
 if(cScore.scoreType==1)
 pts[i+1].y-= contentRect.size.height/3;
 else
 pts[i+1].y-= contentRect.size.height/2;
 [holeNumStr drawAtPoint:pts[i+1] forWidth:LEFT_COLUMN_WIDTH withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
 if(cScore.scoreType==1)
 pts[i+1].y+= contentRect.size.height/3;
 else
 pts[i+1].y+= contentRect.size.height/2;
 }
 else{
 //draw hole number
 NSString *holeNumStr = [formatter stringFromNumber:[NSNumber numberWithInteger:startOffset+i/rows]];
 size = [holeNumStr sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:MIDDLE_COLUMN_WIDTH lineBreakMode:NSLineBreakByTruncatingTail];
 [mainTextColor set];
 [holeNumStr drawAtPoint:pts[i] forWidth:LEFT_COLUMN_WIDTH withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
 
 cScore.holeNumber = (NSInteger)startOffset+i/2;
 
 //draw strokes
 NSInteger		strokes;
 if(section == 1){
 strokes = cScore.curHole.strokeNum2;
 }
 else if(section == 2){
 strokes = cScore.curHole.strokeNum3;
 }
 else if(section == 3){
 strokes = cScore.curHole.strokeNum4;
 }
 else{
 strokes = cScore.curHole.strokeNum;
 }
 
 holeNumStr = [formatter stringFromNumber:[NSNumber numberWithInteger:strokes]];
 iTotal += strokes;
 size = [holeNumStr sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:MIDDLE_COLUMN_WIDTH lineBreakMode:NSLineBreakByTruncatingTail];
 [secondaryTextColor set];
 if(cScore.scoreType==1)
 pts[i+1].y-= contentRect.size.height*2/3;
 else
 pts[i+1].y-= contentRect.size.height/2;
 [holeNumStr drawAtPoint:pts[i+1] forWidth:LEFT_COLUMN_WIDTH withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
 if(cScore.scoreType==1)
 pts[i+1].y+= contentRect.size.height*2/3;
 else
 pts[i+1].y+= contentRect.size.height/2;
 
 //draw stableford
 if(cScore.scoreType==1){
 NSInteger		stbl;
 if(section == 1){
 stbl = cScore.curHole.strokeNum2;
 }
 else if(section == 2){
 stbl = cScore.curHole.strokeNum3;
 }
 else if(section == 3){
 stbl = cScore.curHole.strokeNum4;
 }
 else{
 stbl = cScore.curHole.strokeNum;
 }
 
 holeNumStr = [formatter stringFromNumber:[NSNumber numberWithInteger:stbl]];
 iTotalStbl += stbl;
 size = [holeNumStr sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:MIDDLE_COLUMN_WIDTH lineBreakMode:NSLineBreakByTruncatingTail];
 [secondaryTextColor set];
 pts[i+1].y-= contentRect.size.height/3;
 [holeNumStr drawAtPoint:pts[i+1] forWidth:LEFT_COLUMN_WIDTH withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
 pts[i+1].y+= contentRect.size.height/3;
 }
 
 }
 
 }
 pts[0].x= contentRect.origin.x;
 if(cScore.scoreType==1)
 pts[0].y= contentRect.origin.y + contentRect.size.height/3;
 else
 pts[0].y= contentRect.origin.y + contentRect.size.height/2;
 pts[1].x= contentRect.origin.x+contentRect.size.width;
 if(cScore.scoreType==1)
 pts[1].y= contentRect.origin.y + contentRect.size.height/3;
 else
 pts[1].y= contentRect.origin.y + contentRect.size.height/2;
 CGContextStrokeLineSegments(UIGraphicsGetCurrentContext(), pts, maxBox*rows);
 
 pts[0].x= contentRect.origin.x;
 pts[0].y= contentRect.origin.y;
 NSString *holeStr = [[NSString alloc] initWithString: @"Hole"];
 size = [holeStr sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:MIDDLE_COLUMN_WIDTH lineBreakMode:NSLineBreakByTruncatingTail];
 [mainTextColor set];
 [holeStr drawAtPoint:pts[0] forWidth:LEFT_COLUMN_WIDTH withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
 
 pts[0].x= contentRect.origin.x;
 pts[0].y= contentRect.origin.y + contentRect.size.height/2;
 NSString *scoreStr = [[NSString alloc] initWithString: @"Score"];
 size = [holeStr sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:MIDDLE_COLUMN_WIDTH lineBreakMode:NSLineBreakByTruncatingTail];
 [secondaryTextColor set];
 [scoreStr drawAtPoint:pts[0] forWidth:LEFT_COLUMN_WIDTH withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
 mScore.holeNumber = saveHole;
 }
*/ 


- (void)drawRect:(CGRect)rect {
	
#define MAIN_FONT_SIZE 14
#define MIN_MAIN_FONT_SIZE 12
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10
	
	CGFloat	actualFontSize;
	CGSize	size;
	NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
	// Color and font for the main text items (time zone name, time)
	UIColor *mainTextColor = [UIColor blackColor];
	UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
	
	// Color and font for the secondary text items (GMT offset, day)
	UIColor *secondaryTextColor = [UIColor blueColor];
	
	
	CGRect contentRect = self.bounds;
	NSInteger rows=2;
	if(mScore.scoreType==1)
		rows++;
	
	CGContextStrokeRect(UIGraphicsGetCurrentContext(), contentRect);
	int maxBox=10;
	CGFloat tenth = (contentRect.size.width) / (maxBox+3);
	Score *cScore = mScore;
	
	CGPoint pts[maxBox*2];
	int start = 0;
	int startOffset = 0;
	if((mScore.gameType == kBackNineEnum) || ((mScore.gameType != kBackNineEnum) && row>rows-1))
		startOffset+=9;
	int end=maxBox*2;
	CGFloat startxsize= tenth+tenth;
	if(mScore.scoreType==1)
		startxsize+=tenth*3/4;
	CGFloat startx= contentRect.origin.x +startxsize;
	NSInteger saveHole = cScore.holeNumber;
	int iTotal = 0;
	int iTotalStbl = 0;
	for(int i=start; i<end;i+=2, startx += tenth){
		//lines
		pts[i].x= startx;
		pts[i].y= contentRect.origin.y;
		pts[i+1].x= startx;
		pts[i+1].y= contentRect.origin.y+contentRect.size.height;
		
		if(i == end-2){
			NSString *holeNumStr;
			if(self.row%rows==0){
				holeNumStr= [[NSString alloc] initWithString: @"Total"];
				CGRect rect=CGRectMake(pts[i].x, pts[i].y, tenth*2, contentRect.size.height);
				[mainTextColor set];
				[holeNumStr drawInRect:rect	withFont:mainFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
			}
			else if (self.row%rows ==1){
				holeNumStr = [formatter stringFromNumber:[NSNumber numberWithInteger:iTotal]];
				CGRect rect=CGRectMake(pts[i].x, pts[i].y, tenth, contentRect.size.height);
				[secondaryTextColor set];
				[holeNumStr drawInRect:rect	withFont:mainFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
			}
			else if(self.row%rows ==2){
				holeNumStr = [formatter stringFromNumber:[NSNumber numberWithInteger:iTotalStbl]];
				CGRect rect=CGRectMake(pts[i].x, pts[i].y, tenth, contentRect.size.height);
				[secondaryTextColor set];
				[holeNumStr drawInRect:rect	withFont:mainFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
			}
			size = [holeNumStr sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:tenth*2 lineBreakMode:NSLineBreakByTruncatingTail];
			//[holeNumStr drawAtPoint:pts[i] forWidth:size.width withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		}
		else{
			//draw hole number
			NSString *holeNumStr;
			if(self.row%rows ==0){
				holeNumStr = [formatter stringFromNumber:[NSNumber numberWithInteger:startOffset+1+i/2]];
				[mainTextColor set];
			}
			else if (self.row%rows ==1){
				cScore.holeNumber = (NSInteger)startOffset+1+i/2;
					//draw strokes
					NSInteger		strokes;
					if(section == 1){
						strokes = cScore.curHole.strokeNum2;
					}
					else if(section == 2){
						strokes = cScore.curHole.strokeNum3;
					}
					else if(section == 3){
						strokes = cScore.curHole.strokeNum4;
					}
					else{
						strokes = cScore.curHole.strokeNum;
					}
					
					holeNumStr = [formatter stringFromNumber:[NSNumber numberWithInteger:strokes]];
					iTotal += strokes;
					[secondaryTextColor set];
				}
			else if (self.row%rows ==2){
				cScore.holeNumber = (NSInteger)startOffset+1+i/2;
				//draw strokes
				NSInteger		pts=[mScore stablefordPoints:section];
				
				holeNumStr = [formatter stringFromNumber:[NSNumber numberWithInteger:pts]];
				iTotalStbl += pts;
				[secondaryTextColor set];
			}
			size = [holeNumStr sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:tenth lineBreakMode:NSLineBreakByTruncatingTail];
			//[holeNumStr drawAtPoint:pts[i] forWidth:size.width withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignCenters];
			CGRect rect=CGRectMake(pts[i].x, pts[i].y, tenth, contentRect.size.height);
			[holeNumStr drawInRect:rect	withFont:mainFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];

			
		}
	
	}
	CGContextStrokeLineSegments(UIGraphicsGetCurrentContext(), pts, maxBox*2);
	
	NSString *holeStr;
	if(self.row%rows ==0){
		holeStr = [[NSString alloc] initWithString: @"Hole"];
		[mainTextColor set];
	}
	else if (self.row%rows ==1){
		holeStr = [[NSString alloc] initWithString: @"Score"];
		[secondaryTextColor set];
	}
	else if (self.row%rows ==2){
		holeStr = [[NSString alloc] initWithString: @"Stableford"];
		[secondaryTextColor set];
	}
	pts[0].x= contentRect.origin.x;
	pts[0].y= contentRect.origin.y;
	size = [holeStr sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:startxsize lineBreakMode:NSLineBreakByTruncatingTail];
	[holeStr drawAtPoint:pts[0] forWidth:size.width withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByTruncatingTail baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

	
	mScore.holeNumber = saveHole;
}


- (void)dealloc {
    [super dealloc];
}


@end
