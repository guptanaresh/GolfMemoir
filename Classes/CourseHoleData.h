//
//  Hole.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/18/08.
//  playDate 2008 JAJSoftware. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface CourseHoleData : NSObject {
    // Opaque reference to the underlying database.
    sqlite3 *database;
    // Attributes.
    NSInteger courseID;
    NSInteger holeID;
	NSInteger whitePar;
	NSInteger whiteYard;
	NSInteger blackYard;
	NSInteger blueYard;
	NSInteger orangeYard;
	NSInteger hcp;
	double longitude;
	double latitude;
	NSInteger extraYard;
	NSInteger bool1;
	NSInteger bool2;
	NSInteger holeType;
	double teeLongitude;
	double teeLatitude;
	double frontLongitude;
	double frontLatitude;
	double backLongitude;
	double backLatitude;
}

@property (assign, nonatomic) NSInteger courseID;
@property (assign, nonatomic) NSInteger holeID;
@property (assign, nonatomic) NSInteger whitePar;
@property (assign, nonatomic) NSInteger whiteYard;
@property (assign, nonatomic) NSInteger blackYard;
@property (assign, nonatomic) NSInteger blueYard;
@property (assign, nonatomic) NSInteger orangeYard;
@property (assign, nonatomic) NSInteger hcp;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) NSInteger extraYard;
@property (assign, nonatomic) NSInteger bool1;
@property (assign, nonatomic) NSInteger bool2;
@property (assign, nonatomic) NSInteger holeType;
@property (assign, nonatomic) double teeLongitude;
@property (assign, nonatomic) double teeLatitude;
@property (assign, nonatomic) double frontLongitude;
@property (assign, nonatomic) double frontLatitude;
@property (assign, nonatomic) double backLongitude;
@property (assign, nonatomic) double backLatitude;

// Inserts a new row in the database to be used for a new Hole object.
- (void)insertNewIntoDatabase:(sqlite3 *)database;
// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

// Creates the object with primary key and courseName is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db hole:(NSInteger)num;
// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)fromDB;
// Flushes all but the primary key and courseName out to the database.
- (void)toDB;
// Remove the Hole complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase;

@end

