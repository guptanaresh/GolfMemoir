//
//  ScoreTable.m
//  GolfMemoir
//
//  Created by naresh gupta on 6/8/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import "ScoreCardTable.h"
#import "ScoreCardCell.h"
#import "Constants.h"


@implementation ScoreCardTable

@synthesize mScore;
/*
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		frm=frame;
	}
	return self;
}
*/
-(id)initWithScore:(Score *)aScore
{
	self = [super init];
	mScore = aScore;
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger	sec=1;
	if(mScore.player2Name !=nil)
		sec++;
	if(mScore.player3Name !=nil)
		sec++;
	if(mScore.player4Name !=nil)
		sec++;
	return sec;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
		return kScoreCardRowHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return kScoreCardHeaderHeight;
}



- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	NSInteger rows=2;
	if(mScore.scoreType == 1)
		rows++;
		
	if(mScore.gameType == k18HolesEnum)
		rows = rows*2;
	return rows;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section    // fixed font style. use custom view (UILabel) if you want something different
{
		if(section == 0){
			return [NSString  stringWithFormat:@"My Score (Course HCP: %i)", [mScore calcCourseHandicap:1]];
		}
		else if(section == 1){
			return [NSString  stringWithFormat:@"%@ (Course HCP: %i)", mScore.player2Name, [mScore calcCourseHandicap:2]];
		}
		else if(section == 2){
			return [NSString  stringWithFormat:@"%@ (Course HCP: %i)", mScore.player3Name, [mScore calcCourseHandicap:3]];
		}
		else {
			return [NSString  stringWithFormat:@"%@ (Course HCP: %i)", mScore.player4Name, [mScore calcCourseHandicap:4]];
		}
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
		CGRect startingRect = CGRectMake(0.0, 0.0, 200.0, kScoreCardRowHeight);
		ScoreCardCell *cell = [[[ScoreCardCell alloc] initWithFrame:startingRect] autorelease];
		cell.mScore = self.mScore;
	cell.row = indexPath.row;
	cell.section = indexPath.section;
	cell.selectionStyle =  UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (void)dealloc {
	[super dealloc];
}


@end
