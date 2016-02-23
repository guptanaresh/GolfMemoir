//
//  Score.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/18/08.
//  playDate 2008 JAJSoftware. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Foundation/NSURLConnection.h>
#import <sqlite3.h>
#import "Hole.h"
#import "Course.h"
#import "BTDevice.h"
#import "FBConnect/FBConnect.h"


@interface Score : NSObject
{
    // Opaque reference to the underlying database.
    sqlite3 *database;
    // Primary key in the database.
    NSInteger primaryKey;
    // Attributes.
    NSInteger courseID;
    Course *mCourse;
    NSDate *playDate;
    NSString *player2Name;
    NSString *player3Name;
    NSString *player4Name;
	NSInteger holeNumber;
	NSInteger	 status;
	Hole		*curHole;
	double hcp;
	double hcp2;
	double hcp3;
	double hcp4;
	NSInteger teeType;
	NSInteger serverpk;
	NSInteger gameType;
	double hi;
	double hi2;
	double hi3;
	double hi4;
	double latestHI;
    FBUID fbUID2;
    FBUID fbUID3;
    FBUID fbUID4;
	NSInteger scoreType;
	NSMutableData   *receivedData;
}

// Property exposure for primary key and other attributes. The primary key is 'assign' because it is not an object, 
// nonatomic because there is no need for concurrent access, and readonly because it cannot be changed without 
// corrupting the database.
@property (assign, nonatomic, readonly) NSInteger primaryKey;
// The remaining attributes are copied rather than retained because they are value objects.
@property (assign, nonatomic) NSInteger courseID;
@property (retain, nonatomic) Course *mCourse;
@property (copy, nonatomic) NSDate *playDate;
@property (copy, nonatomic) NSString *player2Name;
@property (copy, nonatomic) NSString *player3Name;
@property (copy, nonatomic) NSString *player4Name;
@property (assign, nonatomic) NSInteger holeNumber;
@property (assign, nonatomic) NSInteger status;
@property (assign, nonatomic) double hcp;
@property (assign, nonatomic) double hcp2;
@property (assign, nonatomic) double hcp3;
@property (assign, nonatomic) double hcp4;
@property (assign, nonatomic) NSInteger teeType;
@property (assign, nonatomic) NSInteger serverpk;
@property (assign, nonatomic) NSInteger gameType;
@property (copy, nonatomic) Hole		*curHole;
@property (assign, nonatomic) double hi;
@property (assign, nonatomic) double hi2;
@property (assign, nonatomic) double hi3;
@property (assign, nonatomic) double hi4;
@property (assign, nonatomic) double latestHI;
@property (assign, nonatomic) FBUID fbUID2;
@property (assign, nonatomic) FBUID fbUID3;
@property (assign, nonatomic) FBUID fbUID4;
@property (assign, nonatomic) NSInteger scoreType;

// Inserts a new row in the database to be used for a new Score object.
+ (NSInteger)insertNewScoreIntoDatabase:(sqlite3 *)database;
// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;
+ (NSInteger)retrieveOpenGameDatabase:(sqlite3 *)database;
// Inserts a new row in the database to be used for a new Score object.
+ (NSMutableArray *)retrieveAllFinishedScores:(sqlite3 *)database;
+ (NSInteger) retrieveScoresCount:(sqlite3 *)database;
-(NSString *)scoreString;

//-(void)initializeHoles:(sqlite3 *)db;

// Creates the object with primary key and courseName is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)fromDB;
// Flushes all but the primary key and courseName out to the database.
- (void)toDB;
// Remove the Score complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase;
+(UIImage *)scaleAndRotateImage:(UIImage *)image;

-(NSInteger)totalScore:(NSInteger) whichPlayer;
- (BOOL)hasPlayer2;
- (BOOL)hasPlayer3;
- (BOOL)hasPlayer4;
-(NSString *) photoString:(BOOL)bLocal;
-(void)upload:(BOOL) bPremium;
-(void)uploadAllImages;
- (void)uploadImage:(NSString *)imgStr;
-(double) calcHandicapDiff:(NSInteger) whichPlayer;
-(NSInteger) calcCourseHandicap:(NSInteger) whichPlayer;
-(NSInteger)totalESCscore:(NSInteger) whichPlayer;
+(NSInteger) escScore:(NSInteger) score forHandicap:(double) hp;
+(double)calcHandicapIndex;
-(void) finish;
-(NSInteger)stablefordPoints:(NSInteger)player;
-(NSMutableString *)toString:(NSInteger)exCourseID;

@end

