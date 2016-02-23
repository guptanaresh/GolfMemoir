//
//  Hole.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/18/08.
//  playDate 2008 JAJSoftware. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Hole : NSObject {
    // Opaque reference to the underlying database.
    sqlite3 *database;
    // Attributes.
    NSInteger scoreID;
    NSInteger holeID;
	NSInteger strokeNum;
	NSInteger strokeNum2;
	NSInteger strokeNum3;
	NSInteger strokeNum4;
	NSInteger distance;
	double longitude;
	double latitude;
	NSInteger putt;
}

@property (assign, nonatomic) NSInteger scoreID;
@property (assign, nonatomic) NSInteger holeID;
@property (assign, nonatomic) NSInteger strokeNum;
@property (assign, nonatomic) NSInteger strokeNum2;
@property (assign, nonatomic) NSInteger strokeNum3;
@property (assign, nonatomic) NSInteger strokeNum4;
@property (assign, nonatomic) NSInteger distance;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) NSInteger putt;

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
- (void)saveStroke;
- (BOOL)readStroke;
- (void)deleteStrokes;
// Remove the Hole complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase;

@end

