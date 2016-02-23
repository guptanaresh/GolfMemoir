//
//  ScoreTable.h
//  GolfMemoir
//
//  Created by naresh gupta on 6/8/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Score.h"


@interface ScoreCardTable : NSObject <UITableViewDataSource, UITableViewDelegate> {
	Score *mScore;
}

@property (nonatomic, assign) Score *mScore;

- (id)initWithScore:(Score *)aScore;

@end
