
#import <UIKit/UIKit.h>
#import "GameHoleViewController.h"

@class ScoreCardCellView;

@interface ScoreCardCell : UITableViewCell {
	ScoreCardCellView *scoreCellView;
	Score *mScore;
	NSUInteger					row;
	NSUInteger					section;
}

@property (nonatomic, assign) Score *mScore;
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) NSUInteger section;
@property (nonatomic, retain) ScoreCardCellView *scoreCellView;

@end
