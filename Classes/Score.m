//
//  Score.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/18/08.
//  playDate 2008 JAJSoftware. All rights reserved.
//

#import "Score.h"
#import "Hole.h"
#import "Constants.h"
#import "Reachability.h"
#import "GolfMemoirAppDelegate.h"

// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *retrieve_statement = nil;
static sqlite3_stmt *retrieve_all_statement = nil;
static sqlite3_stmt *retrieve_count_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;



@implementation Score

@synthesize curHole, mCourse, player2Name, player3Name, player4Name, hcp, hcp2, hcp3, hcp4, teeType, serverpk, gameType,playDate, scoreType;
@synthesize hi;
@synthesize hi2;
@synthesize hi3;
@synthesize hi4;
@synthesize latestHI;
@synthesize fbUID2;
@synthesize fbUID3;
@synthesize fbUID4;

// Creates a new empty Score record in the database. The primary key is returned, presumably to be used to alloc/init 
// a new Score object. This method is a class method - it can be called without involving an instance of the class.
+ (NSInteger)insertNewScoreIntoDatabase:(sqlite3 *)database {
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (insert_statement == nil) {
        char *sql = "INSERT INTO score (courseID, holeNumber, status) VALUES(?,?,?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	sqlite3_bind_int(insert_statement, 1, 0);
	sqlite3_bind_int(insert_statement, 2, 1);
	sqlite3_bind_int(insert_statement, 3, 0);
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
	//[Score finalizeStatements];
    if (success != SQLITE_ERROR) {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        int pkid= sqlite3_last_insert_rowid(database);
		
		return pkid;
    }
    NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    return -1;
}

// Creates a new empty Score record in the database. The primary key is returned, presumably to be used to alloc/init 
// a new Score object. This method is a class method - it can be called without involving an instance of the class.
+ (NSInteger)retrieveOpenGameDatabase:(sqlite3 *)database {
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (retrieve_statement == nil) {
		char *sql = "SELECT * FROM score WHERE status=?";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	sqlite3_bind_int(retrieve_statement, 1, 0);
    int success = sqlite3_step(retrieve_statement);
	NSInteger	pk;
	//if (sqlite3_step(retrieve_statement) == SQLITE_ROW) {
	if (success == SQLITE_ROW) {
		pk = sqlite3_column_int(retrieve_statement, 0);
	} else {
		pk = -1;
	}
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(retrieve_statement);
    return pk;
}

+ (NSInteger) retrieveScoresCount:(sqlite3 *)database {
    if (retrieve_count_statement == nil) {
		char *sql = "SELECT count(*) FROM score";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_count_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	
    int success = sqlite3_step(retrieve_count_statement);
	NSInteger	count=0;
	if (success == SQLITE_ROW) {
		count = sqlite3_column_int(retrieve_count_statement, 0);
	}	
    sqlite3_reset(retrieve_count_statement);
	return count;
}

+ (NSMutableArray *)retrieveAllFinishedScores:(sqlite3 *)database {
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (retrieve_all_statement == nil) {
//		static char *sql = "SELECT * FROM score WHERE status=? ORDER BY playDate desc";
		char *sql = "SELECT * FROM score ORDER BY playDate desc";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_all_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
//	sqlite3_bind_int(retrieve_all_statement, 1, 1);
    NSMutableArray *scoreArray = [[NSMutableArray alloc] init];

		// We "step" through the results - once for each row.
		while (sqlite3_step(retrieve_all_statement) == SQLITE_ROW) {
			// The second parameter indicates the column index into the result set.
			int primaryKey = sqlite3_column_int(retrieve_all_statement, 0);
			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
			// autorelease is slightly more expensive than release. This design choice has nothing to do with
			// actual memory management - at the end of this block of code, all the book objects allocated
			// here will be in memory regardless of whether we use autorelease or release, because they are
			// retained by the books array.
			Score *aScore = [[Score alloc] initWithPrimaryKey:primaryKey database:database];
			[aScore fromDB];
			[scoreArray addObject:aScore];
			[aScore release];
		}

    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(retrieve_all_statement);
    return scoreArray;
}

/*
-(void)initializeHoles:(sqlite3 *)db {
	NSMutableArray *hl = [NSMutableArray arrayWithCapacity:18];
	for(int i=0; i < 18; i++){
		
		Hole *aHole=[[Hole alloc] initWithPrimaryKey:self.primaryKey database:db hole:i+1];
		[hl addObject:aHole];
		
	}	
	holes =  hl;
}
*/

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (retrieve_statement) sqlite3_finalize(retrieve_statement);
    if (retrieve_all_statement) sqlite3_finalize(retrieve_all_statement);
    if (retrieve_count_statement) sqlite3_finalize(retrieve_count_statement);
    if (init_statement) sqlite3_finalize(init_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (hydrate_statement) sqlite3_finalize(hydrate_statement);
    if (dehydrate_statement) sqlite3_finalize(dehydrate_statement);
}

// Creates the object with primary key and courseName is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
    if (self = [super init]) {
        primaryKey = pk;
        database = db;
		[self fromDB];
    }
    return self;
}

- (void)dealloc {
    //[player2Name release];
    //[player3Name release];
    //[player4Name release];
    //[playDate release];
	[mCourse release];
	[curHole release];
    [super dealloc];
}

- (void)deleteFromDatabase {
    if (delete_statement == nil) {
        char *sql = "DELETE FROM score WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement, 1, primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_statement);

	if(success == SQLITE_DONE){
		// Compile the delete statement if needed.
		for(NSInteger hole=1; hole <=18 ; hole +=1){
			self.holeNumber = hole;
			[curHole deleteFromDatabase];
		}
	
	}
		
}

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)fromDB {
    // Check if action is necessary.
    // Compile the hydration statement, if needed.
    if (hydrate_statement == nil) {
        char *sql = "SELECT * FROM score WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(hydrate_statement, 1, primaryKey);
    // Execute the query.
    int success =sqlite3_step(hydrate_statement);
    if (success == SQLITE_ROW) {
        self.courseID = sqlite3_column_int(hydrate_statement, 1);
        self.playDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(hydrate_statement, 2)];
        char *str = (char *)sqlite3_column_text(hydrate_statement, 3);
        self.player2Name = (str) ? [NSString stringWithUTF8String:str] : nil;
        str = (char *)sqlite3_column_text(hydrate_statement, 4);
        self.player3Name = (str) ? [NSString stringWithUTF8String:str] : nil;
        str = (char *)sqlite3_column_text(hydrate_statement, 5);
        self.player4Name = (str) ? [NSString stringWithUTF8String:str] : nil;
        self.holeNumber = sqlite3_column_int(hydrate_statement, 6);
        self.status = sqlite3_column_int(hydrate_statement, 7);
        self.hcp = sqlite3_column_double(hydrate_statement, 8);
        self.hcp2 = sqlite3_column_double(hydrate_statement, 9);
		//there is a dummy field @ location 10 in the record;ignore
        sqlite3_column_int(hydrate_statement, 10);
        self.hcp3 = sqlite3_column_double(hydrate_statement, 11);
        self.hcp4 = sqlite3_column_double(hydrate_statement, 12);
        self.teeType = sqlite3_column_int(hydrate_statement, 13);
        self.serverpk = sqlite3_column_int(hydrate_statement, 14);
		self.gameType=sqlite3_column_int(hydrate_statement, 15);;
		self.hi = sqlite3_column_double(hydrate_statement, 16);
        self.hi2 = sqlite3_column_double(hydrate_statement, 17);
        self.hi3 = sqlite3_column_double(hydrate_statement, 18);
        self.hi4 = sqlite3_column_double(hydrate_statement, 19);
        self.latestHI = sqlite3_column_double(hydrate_statement, 20);
        self.fbUID2 = sqlite3_column_int(hydrate_statement, 21);
        self.fbUID3 = sqlite3_column_int(hydrate_statement, 22);
        self.fbUID4 = sqlite3_column_int(hydrate_statement, 23);
		self.scoreType=sqlite3_column_int(hydrate_statement, 24);
   } else {
        // The query did not return 
        self.courseID = 0;
        self.player2Name = nil;
        self.player3Name = nil;
        self.player4Name = nil;
        self.playDate = [NSDate date];
        self.holeNumber = 1;
        self.status = 0;
		self.hcp = 0.0;
        self.hcp2 = 0.0;
        self.hcp3 = 0.0;
        self.hcp4 = 0.0;
        self.teeType = kWhiteTee;
        self.serverpk = 0;
        self.gameType = 0;
	   self.hi = 0.0;
	   self.hi2 = 0.0;
	   self.hi3 = 0.0;
	   self.latestHI = 0.0;
	   self.fbUID2 = 0;
	   self.fbUID3 = 0;
	   self.fbUID4 = 0;
	   self.scoreType=0;
   }
	// Reset the query for the next use.
	sqlite3_reset(hydrate_statement);

	if(!(courseID == 0 || courseID == -1)){
		if(mCourse == nil){
			mCourse = [[Course alloc] initWithPrimaryKey:courseID database:database];
			mCourse.holeNumber = self.holeNumber;
		}
		[mCourse fromDB];
	}
	
	if(curHole !=nil)
		[curHole release];
	curHole=[[Hole alloc] initWithPrimaryKey:self.primaryKey database:database hole:holeNumber];
}

// Flushes all but the primary key and courseName out to the database.
- (void)toDB {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (dehydrate_statement == nil) {
            char *sql = "UPDATE score SET courseID=?, player2Name=?, player3Name=?, player4Name=?,  playDate=?, holeNumber=?, status=?, hcp=?, hcp2=?, hcp3=?, hcp4=?, teeType=?, serverpk=?, gameType=? , hi=?, hi2=?, hi3=?, hi4=?, latestHI=?,fbUID2=?,fbUID3=?,fbUID4=?,scoreType=? WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
        sqlite3_bind_int(dehydrate_statement, 1, courseID);
	sqlite3_bind_text(dehydrate_statement, 2, [player2Name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dehydrate_statement, 3, [player3Name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dehydrate_statement, 4, [player4Name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(dehydrate_statement, 5, [playDate timeIntervalSince1970]);
        sqlite3_bind_int(dehydrate_statement, 6, holeNumber);
        sqlite3_bind_int(dehydrate_statement, 7, status);
	sqlite3_bind_double(dehydrate_statement, 8, hcp);
	sqlite3_bind_double(dehydrate_statement, 9, hcp2);
	sqlite3_bind_double(dehydrate_statement, 10, hcp3);
	sqlite3_bind_double(dehydrate_statement, 11, hcp4);
	sqlite3_bind_int(dehydrate_statement, 12, teeType);
	sqlite3_bind_int(dehydrate_statement, 13, serverpk);
	sqlite3_bind_int(dehydrate_statement, 14, gameType);
	sqlite3_bind_double(dehydrate_statement, 15, hi);
	sqlite3_bind_double(dehydrate_statement, 16, hi2);
	sqlite3_bind_double(dehydrate_statement, 17, hi3);
	sqlite3_bind_double(dehydrate_statement, 18, hi4);
	sqlite3_bind_double(dehydrate_statement, 19, latestHI);
	sqlite3_bind_int(dehydrate_statement, 20, fbUID2);
	sqlite3_bind_int(dehydrate_statement, 21, fbUID3);
	sqlite3_bind_int(dehydrate_statement, 22, fbUID4);
	sqlite3_bind_int(dehydrate_statement, 23, scoreType);
	sqlite3_bind_int(dehydrate_statement, 24, primaryKey);
	// Execute the query.
        int success = sqlite3_step(dehydrate_statement);
        // Reset the query for the next use.
        sqlite3_reset(dehydrate_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
		[curHole toDB];
		if(!(courseID == 0 || courseID == -1)){
			[mCourse toDB];
		}
}

#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

- (NSInteger)primaryKey {
    return primaryKey;
}

- (NSInteger)courseID {
    return courseID;
}

- (void)setCourseID:(NSInteger)aID {
    courseID = aID;
}

/*
- (NSDate *)playDate {
    return playDate;
}

- (void)setPlayDate:(NSDate *)aDate {
    if ((!playDate && !aDate) || (playDate && aDate && [playDate isEqualToDate:aDate])) return;
    [playDate release];
    playDate = [aDate copy];
}
*/

- (NSInteger)holeNumber {
    return holeNumber;
}

- (void)setHoleNumber:(NSInteger)aNum {
	if(holeNumber != aNum){
		holeNumber = aNum;
		mCourse.holeNumber=aNum;
		curHole.holeID=aNum;
		[curHole fromDB];
	}
}
- (NSInteger)status {
    return status;
}

- (void)setStatus:(NSInteger)aNum {
	status = aNum;
}

- (void)setCurHole:(Hole *)newHole 
{ 
	if (curHole != newHole) { 
		[curHole release]; 
		curHole = [newHole copy]; 
	} 
} 

-(NSComparisonResult)compareScore:(Score *) another
{
	double myScore=self.hcp;
	double anotherScore=another.hcp;
	if(myScore == anotherScore)
		return NSOrderedSame;
		else if(myScore > anotherScore)
			return NSOrderedDescending;
			else
				return NSOrderedAscending;
}

+(double)calcHandicapIndex
{	
	UIApplication *app = [UIApplication sharedApplication];
	GolfMemoirAppDelegate *deleg = (GolfMemoirAppDelegate *)[app delegate];
	NSMutableArray *lScores=[[NSMutableArray alloc] init];
	NSMutableArray *scoreList = [Score retrieveAllFinishedScores:deleg.database];
	NSUInteger count=[scoreList count];
	NSUInteger iTotal=0;
	for(NSUInteger i=0; i<count; i++){
		Score *aScore=[scoreList objectAtIndex:i];
		if( [aScore totalESCscore:0] > kBadMinScore){
			[lScores addObject:aScore];
			iTotal++;
			if(iTotal >= 20)
				break;
		}
	}
	
	[lScores sortUsingSelector:@selector(compareScore:)];
	count=[lScores count];
	if(count < 5){
		count=0;
	}
	else if( count == 5 || count ==6){
		count=1;
	}
	else if( count == 7 || count ==8){
		count=2;
	}
	else if( count == 9 || count ==10){
		count=3;
	}
	else if( count == 11 || count ==12){
		count=4;
	}
	else if( count == 13 || count ==14){
		count=5;
	}
	else if( count == 15 || count ==16){
		count=6;
	}
	else{
		count-=10;
	}
	
	double hcp=0.0;
	if(count == 0){
		hcp=kInvalidHI;
	}
	else{
		for(NSUInteger i=0; i<count; i++){
			Score *aScore=[lScores objectAtIndex:i];
			hcp += aScore.hcp;
		}
		hcp /=count;
		hcp *= .96;
	}
	return hcp;
}	
	
-(NSString *)scoreString
{
	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	dateFormat.dateStyle = kCFDateFormatterShortStyle;
	//dateFormat.timeStyle = kCFDateFormatterShortStyle;
	NSString *dt = [dateFormat stringFromDate:playDate];
	[dateFormat release];
	return [[dt stringByAppendingString:@" @ "] stringByAppendingString:mCourse.courseName];
}

-(NSInteger)totalScore:(NSInteger) whichPlayer
{
	NSInteger iTotal = 0;
	NSInteger saveHole = self.holeNumber;
	for(int i=1; i<=18;i+=1)
	{
		self.holeNumber = i;
		if(whichPlayer==2)
			iTotal += self.curHole.strokeNum2;
		else if (whichPlayer==3)
			iTotal += self.curHole.strokeNum3;
		else if (whichPlayer==4)
			iTotal += self.curHole.strokeNum4;
		else
			iTotal += self.curHole.strokeNum;
	}
	self.holeNumber = saveHole;
	return (NSInteger)iTotal;
}

-(NSInteger)totalESCscore:(NSInteger) whichPlayer
{
	NSInteger iTotal = 0;
	NSInteger iScore;
	NSInteger saveHole = self.holeNumber;
	for(int i=1; i<=18;i+=1)
	{
		self.holeNumber = i;
		if(whichPlayer==2)
			iScore= [Score escScore:self.curHole.strokeNum2 forHandicap:self.hi2];
		else if (whichPlayer==3)
			iScore= [Score escScore:self.curHole.strokeNum3 forHandicap:self.hi3];
		else if (whichPlayer==4)
			iScore= [Score escScore:self.curHole.strokeNum4 forHandicap:self.hi4];
		else
			iScore= [Score escScore:self.curHole.strokeNum forHandicap:self.hi];
		iTotal+=iScore;
	}
	self.holeNumber = saveHole;
	return (NSInteger)iTotal;
}

+(NSInteger) escScore:(NSInteger) score forHandicap:(double) hp
{
	double handicap=hp;
	if(handicap==0)
		handicap=kMaxHandicapIndex;
	if( handicap >= 0 && handicap <=9)
	{
		if(score >=6)
			return 6;
		else
			return score;
	}
	else if(handicap >=10 && handicap <=19)
	{
		if(score >=7)
			return 7;
		else
			return score;
	}
	else if(handicap >= 20 && handicap <=29)
	{
		if(score >=8)
			return 8;
		else
			return score;
	}
	else if(handicap >=30 && handicap <=39)
	{
		if(score >=9)
			return 9;
		else
			return score;
	}
	else if(handicap >=40)
	{
		if(score >=10)
			return 10;
		else
			return score;
	}
	else
		return score;
}
+(NSInteger) defSlope:(NSInteger)slope
{
	if(slope <= 0)
		return 113;
	else
		return slope;
}
+(double) defCourseRating:(double)courseRating
{
	if(courseRating <= 0.0)
		return 72.0;
	else
		return courseRating;
}
-(double) calcHandicapDiff:(NSInteger) whichPlayer
{
	NSInteger escScore=[self totalESCscore:whichPlayer];
	double sc=0.0;
	double adjCourseRating = 1.0;
	if(self.gameType != k18HolesEnum){
		adjCourseRating=2.0;
	}
	if(self.teeType==kWhiteTee){
		sc=((double)(escScore - [Score defCourseRating:self.mCourse.whiteRate]/adjCourseRating) * 113 )/[Score defSlope:self.mCourse.whiteSlope];
	}
	else if(self.teeType==kBlackTee){
		sc=((double)(escScore - [Score defCourseRating:self.mCourse.blackRate]/adjCourseRating) * 113 )/[Score defSlope:self.mCourse.blackSlope];
	}
	else if(self.teeType==kBlueTee){
		sc=((double)(escScore - [Score defCourseRating:self.mCourse.blueRate]/adjCourseRating) * 113 )/[Score defSlope:self.mCourse.blueSlope];
	}
	else if(self.teeType==kRedTee){
		sc=((double)(escScore - [Score defCourseRating:self.mCourse.orangeRate]/adjCourseRating) * 113 )/[Score defSlope:self.mCourse.orangeSlope];
	}
	
	return sc;
}

-(NSInteger) calcCourseHandicap:(NSInteger) whichPlayer
{
	NSInteger hIndex=36;
	if(whichPlayer==2)
		hIndex= self.hi2;
	else if (whichPlayer==3)
		hIndex= self.hi3;
	else if (whichPlayer==4)
		hIndex= self.hi4;
	else
		hIndex= self.hi;
	if(hIndex ==0)
		hIndex= 36;

	if(self.teeType==kWhiteTee){
		return (hIndex * [Score defSlope:self.mCourse.whiteSlope])/113;
	}
	else if(self.teeType==kBlackTee){
		return (hIndex * [Score defSlope:self.mCourse.blackSlope])/113;
	}
	else if(self.teeType==kBlueTee){
		return (hIndex * [Score defSlope:self.mCourse.blueSlope])/113;
	}
	else /*(self.teeType==kRedTee)*/{
		return (hIndex * [Score defSlope:self.mCourse.orangeSlope])/113;
	}
	
}

-(NSInteger)stablefordPoints:(NSInteger)player
{
	NSInteger pts;
	NSInteger fixed=mCourse.curHole.whitePar;
	NSInteger strokes;
	if(player == 1){
		strokes =  curHole.strokeNum2;
	}
	else if(player == 2){
		strokes = curHole.strokeNum3;
	}
	else if(player == 3){
		strokes = curHole.strokeNum4;
	}
	else{
		strokes = curHole.strokeNum;
	}
	if(strokes>0){
	   pts = fixed - strokes+2;
	}
	else{
		pts=0;
	}
	if(pts <0)
		pts=0;
	return pts;
}

- (BOOL)hasPlayer2
{
	return (player2Name != nil) && (player2Name.length > 0);
}
- (BOOL)hasPlayer3
{
	return (player3Name != nil) && (player3Name.length > 0);
}
- (BOOL)hasPlayer4
{
	return (player4Name != nil) && (player4Name.length > 0);
}


-(NSString *) photoString:(BOOL)bLocal
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	/*
	 NSFileManager *fileManager = [NSFileManager defaultManager];
	 NSError *error;
	 NSArray *files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
	 for(int i=0; i<files.count;i++){
	 NSObject *fl=[files objectAtIndex:i];
	 NSLog(fl);
	 NSDictionary *dData = [fileManager attributesOfItemAtPath:[documentsDirectory stringByAppendingPathComponent:fl] error:&error];
	 NSLog(@"File size: %qi\n", [[dData objectForKey:@"NSFileSize"] unsignedLongLongValue]);
	 }
	 */
	NSString *str;
	if(bLocal)
		str=[[NSString alloc] initWithFormat:@"%i.%i.jpg", self.primaryKey, self.holeNumber];
	else
		str=[[NSString alloc] initWithFormat:@"%i.%i.jpg", self.serverpk, self.holeNumber];
		
	NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:str];
	[str release];
	return writablePath;
}	

+(UIImage *)scaleAndRotateImage:(UIImage *)image
{
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}



-(void)upload:(BOOL) bPremium
{
	if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Can't upload score information because there is no internet connection available."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else{
		NSInteger exCourseID=[mCourse upload];
		NSURL *url = [NSURL URLWithString:@"http://www.golfmemoir.com/score_upload.php"]; 
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
		[request setHTTPMethod:@"POST"];
		
		NSMutableString *post = [self toString:exCourseID];		
		NSLog(@"%@", post);
		
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPBody:postData];	
		
		NSError *error;
		NSData *searchData;
		NSHTTPURLResponse *response;
		
		//==== Synchronous call to upload
		searchData = [ NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		if(!searchData) {
			NSLog(@"%@", [error description]);
			[error release];
		} else {
			NSString *str = [[NSString alloc] initWithData:searchData encoding:NSASCIIStringEncoding];
			NSLog(@"%@", str);
			int downpk=[str intValue];
			serverpk = downpk;
			[self toDB];
			if(bPremium)
				[self uploadAllImages];
		}
	}
}	

-(NSMutableString *)toString:(NSInteger)exCourseID
{
	NSMutableString *post = [NSMutableString stringWithFormat:@"udid=%@&courseID=%i&serverpk=%i", 
							 [[UIDevice currentDevice] identifierForVendor],
							 exCourseID,
							 serverpk];
	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	NSString *dt = [dateFormat stringFromDate:playDate];
	[dateFormat release];
	[post appendFormat:@"&playDate=%@&player2Name=%@&player3Name=%@&player4Name=%@&holeNumber=%i&status=%i&hcp=%f&hcp2=%f&hcp3=%f&hcp4=%f&teeType=%i&gameType=%i&hi=%f&hi2=%f&hi3=%f&hi4=%f&latestHI=%f&fbUID2=%lli&fbUID3=%lli&fbUID4=%lli&scoreType=%i",
	 dt,
	 player2Name, 
	 player3Name,
	 player4Name,
	 holeNumber, status, hcp, hcp2, hcp3, hcp4, teeType, gameType,hi, hi2, hi3, hi4,latestHI,fbUID2, fbUID3, fbUID4, scoreType];
	NSInteger curHoleNumber= holeNumber;
	for(int i=0; i <18; i++){
		self.holeNumber=i+1;
		[post appendFormat:@"&strokeNum[%i]=%i",i,self.curHole.strokeNum];
		[post appendFormat:@"&strokeNum2[%i]=%i",i,self.curHole.strokeNum2];
		[post appendFormat:@"&strokeNum3[%i]=%i",i,self.curHole.strokeNum3];
		[post appendFormat:@"&strokeNum4[%i]=%i",i,self.curHole.strokeNum4];
		
		NSInteger curStroke= self.curHole.strokeNum;
		for(int j=1;; j++){
			self.curHole.strokeNum=j;
			if(![curHole readStroke])
				break;
			[post appendFormat:@"&distance%i[%i]=%i",i,j,self.curHole.distance];
			[post appendFormat:@"&longitude%i[%i]=%f",i,j,self.curHole.longitude];
			[post appendFormat:@"&latitude%i[%i]=%f",i,j,self.curHole.latitude];
			[post appendFormat:@"&putt%i[%i]=%i",i,j,self.curHole.putt];
		}
		self.curHole.strokeNum = curStroke;
		[curHole readStroke];
	}
	
	self.holeNumber=curHoleNumber;
	return post;
}	

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}


-(void)uploadAllImages
{
	NSInteger lastHole = holeNumber;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for(int i=1; i<=18; i++){
		self.holeNumber=i;
		NSString *imgStr= [self photoString:TRUE];
		if( [fileManager fileExistsAtPath:imgStr]){
			[self uploadImage:imgStr];
		}
	}
	
	self.holeNumber=lastHole;
}
-(void)deleteAllImages
{
	NSInteger lastHole = holeNumber;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for(int i=1; i<=18; i++){
		self.holeNumber=i;
		NSString *imgStr= [self photoString:TRUE];
		if( [fileManager fileExistsAtPath:imgStr]){
			NSError *error;
			[fileManager removeItemAtPath:imgStr error:&error];
		}
	}
	
	self.holeNumber=lastHole;
}

- (void)uploadImage:(NSString *)imgStr
{
	NSLog(@"%@", imgStr);
	NSData *imageData=[[NSData alloc] initWithContentsOfFile:imgStr];
	UIDevice *dev = [UIDevice currentDevice];
	NSString *uniqueId = dev.identifierForVendor;
	
	NSString *urlString = [@"http://www.golfmemoir.com/image_upload.php?" stringByAppendingFormat:@"udid=%@", uniqueId];
	// urlString = [urlString stringByAppendingString:@"&lang=en_US.UTF-8"];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	// [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	// [request setValue:@"application/" forHTTPHeaderField:@"Content-Length"];
	
	//Add the header info
	NSString *stringBoundary = @"0xKhTmLbOuNdArY";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	
	/* 
		//add key values from the NSDictionary object
		NSEnumerator *keys = [postKeys keyEnumerator];
		int i;
		for (i = 0; i < [postKeys count]; i++) {
			NSString *tempKey = [keys nextObject];
			[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",tempKey] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[[NSString stringWithFormat:@"%@",[postKeys objectForKey:tempKey]] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		}
	*/
	
	//add data field and file data
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", [self photoString:FALSE]] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithData:imageData]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// ---------
		[request setHTTPBody:postBody];
		NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		if(conn) {
				receivedData = [[NSMutableData data] retain];
				[conn retain];	
				NSLog(@"image posted");
		} else {
		        NSLog(@"photo: upload failed!");
		 }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{ 
	// this method is called when the server has determined that it 
	// has enough information to create the NSURLResponse 
	// it can be called multiple times, for example in the case of a 
	// redirect, so each time we reset the data. 
	// receivedData is declared as a method instance elsewhere 
	[receivedData setLength:0]; 
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{ 
	// append the new data to the receivedData 
	// receivedData is declared as a method instance elsewhere 
	[receivedData appendData:data]; 
} 


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{ 
	// release the connection, and the data object
	[connection release]; 
	// receivedData is declared as a method instance elsewhere 
	[receivedData release]; 
	// inform the user 
	NSLog(@"Connection failed! Error - %@ %@", 
		  [error localizedDescription], 
		  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
} 

- (unsigned char*) getData
{
	int urlLength = [receivedData length];
	unsigned char *downloadBuffer;
	
	downloadBuffer = (unsigned char*) malloc (urlLength);
	
	[receivedData getBytes: (unsigned char*)downloadBuffer];
	
	return downloadBuffer;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{ 
	// do something with the data 
	// receivedData is declared as a method instance elsewhere 
	NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]); 
	// release the connection, and the data object 
	NSLog(@"%P", [receivedData bytes]); 
	
}

-(void) finish
{
	status=1;
	hcp=[self calcHandicapDiff:1];
	hcp2=[self calcHandicapDiff:2];
	hcp3=[self calcHandicapDiff:3];
	hcp4=[self calcHandicapDiff:4];
	[self toDB];
	latestHI=[Score calcHandicapIndex];
	[self toDB];
	User *myUser = [[User alloc] initWithDB:database];
	myUser.latestHI=latestHI;
	[myUser toDB];
}

/*
 -(void)postImage:(UIImage*)theImage{
 
 NSString *url = @"serverURL";
 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url]];
 [request setHTTPMethod: @"POST"];
 
 
 NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"defaultphoto.jpg"], 0.75);
 //NSData *data = UIImagePNGRepresentation(theImage);
 
 [request addValue:[NSString stringWithFormat:@"%ld", [data length]]  forHTTPHeaderField:@"Content-Length"];
 [request addValue:@"image/jpeg"  forHTTPHeaderField:@"Content-Type"];
 [request setHTTPBody: data];
 NSURLConnection *conn = [NSURLConnection connectionWithRequest: request delegate: self];
 
 [conn retain];	
 NSLog(@"image posted");
 }
 
 - (void)uploadImage:(UIImage *)image forEdit:(NSUInteger)edit atLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
 {
 NSString *filename = @"upload.jpg";
 NSString *boundary = @"----FOO";
 
 NSURL *url = [NSURL URLWithString:@"http://software.logichigh.com/ihunt/iphone/uploadimage.php"];
 NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
 [req setHTTPMethod:@"POST"];
 
 
 NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
 [req setValue:contentType forHTTPHeaderField:@"Content-type"];
 
 NSData *imageData = UIImageJPEGRepresentationFromOrientation(image, .7);
 // NSData *imageData = UIImageJPEGRepresentation(image, .7);
 
 [self.delegate dataError:[NSString stringWithFormat:@"Data Length %d",[imageData length]]];
 
 //adding the body:
 NSMutableData *postBody = [NSMutableData data];
 [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[@"Content-Disposition: form-data; name= \"key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[[user key] dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[@"Content-Disposition: form-data; name= \"latitude\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[[NSString stringWithFormat:@"%f",latitude] dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[@"Content-Disposition: form-data; name= \"longitude\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[[NSString stringWithFormat:@"%f",longitude] dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:imageData];
 [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[@"Content-Disposition: form-data; name= \"hunt\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[[NSString stringWithFormat:@"%lx", edit] dataUsingEncoding:NSUTF8StringEncoding]];
 [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
 [req setHTTPBody:postBody];
 
 
 self.connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
 self.data = [[NSMutableData data] retain];
 }
 +- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
 0
 {
 0
 +    NSLog(@"photo: picked image");
 0
 +    // NSString * jsCallBack = nil; 
 0
 
 0
 +	// Dismiss the image selection, hide the picker and show the image view with the picked image
 0
 [picker dismissViewControllerAnimated:YES completion:nil];
 0
 imagePickerController.view.hidden = YES;
 0
 -	NSLog(@"Photo Picked");
 0
 -	NSData * imageData = UIImageJPEGRepresentation(image2, 75);
 0
 
 0
 -//	NSURLRequest * systemPost = [self sendPhotoToCallback:imageData];
 0
 +  	UIDevice * dev = [UIDevice currentDevice];
 0
 +	NSString *uniqueId = dev.uniqueIdentifier;
 0
 +    NSData * imageData = UIImageJPEGRepresentation(image, 0.75);	
 0
 +	//NSData * imageData = UIImagePNGRepresentation(image);	
 0
 +	// NSString *postLength = [NSString stringWithFormat:@"%d", [imageData length]];	
 0
 +	NSString *urlString = [@"http://http://phonegap.com/demo/upload.php?" stringByAppendingString:@"uid="];
 0
 +	urlString = [urlString stringByAppendingString:uniqueId];
 0
 +	// urlString = [urlString stringByAppendingString:@"&lang=en_US.UTF-8"];
 0
 +	
 0
 +	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
 0
 +	[request setURL:[NSURL URLWithString:urlString]];
 0
 +	[request setHTTPMethod:@"POST"];
 0
 +	// [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
 0
 +    // [request setValue:@"application/" forHTTPHeaderField:@"Content-Length"];
 0
 +	
 0
 +	// ---------
 0
 +	
 0
 
 0
 -	// Dismiss the image selection, hide the picker and show the image view with the picked image
 0
 -	//[picker dismissViewControllerAnimated:YES completion:nil];
 0
 -	//imagePickerController.view.hidden = YES;
 0
 -
 0
 +    //Add the header info
 0
 +	NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
 0
 +	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
 0
 +	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
 0
 +	
 0
 +	//create the body
 0
 +	NSMutableData *postBody = [NSMutableData data];
 0
 +	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
 0
 +	
 0
 0
 +	 //add key values from the NSDictionary object
 0
 +	 NSEnumerator *keys = [postKeys keyEnumerator];
 0
 +	 int i;
 0
 +	 for (i = 0; i < [postKeys count]; i++) {
 0
 +	 NSString *tempKey = [keys nextObject];
 0
 +	 [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",tempKey] dataUsingEncoding:NSUTF8StringEncoding]];
 0
 +	 [postBody appendData:[[NSString stringWithFormat:@"%@",[postKeys objectForKey:tempKey]] dataUsingEncoding:NSUTF8StringEncoding]];
 0
 +	 [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
 0
 +	 }
 0
 0
 +	
 0
 +	//add data field and file data
 0
 +	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
 0
 +	[postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
 0
 +	[postBody appendData:[NSData dataWithData:imageData]];
 0
 +	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
 0
 +	
 0
 +	// ---------
 0
 +    
 0
 +	[request setHTTPBody:postBody];
 0
 +	
 0
 +	NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
 0
 +	if(conn) {
 0
 +		NSLog(@"photo: connection sucess");
 0
 +		//receivedData = [[NSMutableData data] retain];
 0
 +		NSString *output = [NSString stringWithCString:[conn bytes] length:[conn length]];  
 0
 +		NSLog(@"Page = %@", output);
 0
 +	} else {
 0
 +        NSLog(@"photo: upload failed!");
 0
 +    }
 0
 +	
 0
 +    // Remove the picker interface and release the picker object.
 0
 0
 +	 [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
 0
 +	 [picker release];
 0
 0
 +	
 0
 webView.hidden = NO;
 0
 [window bringSubviewToFront:webView];
 0
 }
 */


@end

