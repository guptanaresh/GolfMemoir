

#import <UIKit/UIKit.h>
#import "GameHoleViewController.h"
#import "Constants.h"


@interface ScoreCardCellView : UIView {
	Score *mScore;
	NSUInteger					row;
	NSUInteger					section;
}

@property (nonatomic, assign) Score *mScore;
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) NSUInteger section;

@end
