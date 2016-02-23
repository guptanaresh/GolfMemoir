//
//  Score.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/18/08.
//  playDate 2008 JAJSoftware. All rights reserved.
//

#import "CourseHoleData.h"
#import "Constants.h"

// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_hole_statement = nil;
static sqlite3_stmt *retrieve_hole_statement = nil;
static sqlite3_stmt *init_hole_statement = nil;
static sqlite3_stmt *delete_hole_statement = nil;
static sqlite3_stmt *hydrate_hole_statement = nil;
static sqlite3_stmt *dehydrate_hole_statement = nil;


@implementation CourseHoleData;
@synthesize courseID;
@synthesize holeID;
@synthesize whitePar;
@synthesize whiteYard;
@synthesize blackYard;
@synthesize blueYard;
@synthesize orangeYard;
@synthesize hcp;
@synthesize longitude;
@synthesize latitude;
@synthesize extraYard;
@synthesize bool1;
@synthesize bool2;
@synthesize holeType;
@synthesize teeLongitude;
@synthesize teeLatitude;
@synthesize frontLongitude;
@synthesize frontLatitude;
@synthesize backLongitude;
@synthesize backLatitude;


// Creates a new empty Score record in the database. The primary key is returned, presumably to be used to alloc/init 
// a new Score object. This method is a class method - it can be called without involving an instance of the class.
-(void)insertNewIntoDatabase:(sqlite3 *)db {
		if (insert_hole_statement == nil) {
        static char *sql = "INSERT INTO coursehole (courseID, holeID, whitePar, whiteYard, blackYard, blueYard, orangeYard, hcp, longitude, latitude, extraYard, bool1, bool2, holeType, teeLongitude, teeLatitude,frontLongitude, frontLatitude,backLongitude, backLatitude) Values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        if (sqlite3_prepare_v2(db, sql, -1, &insert_hole_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prewhitePare statement with message '%s'.", sqlite3_errmsg(db));
        }
		}
	sqlite3_bind_int(insert_hole_statement, 1, self.courseID);
	sqlite3_bind_int(insert_hole_statement, 2, self.holeID);
	sqlite3_bind_int(insert_hole_statement, 3, self.whitePar);
	sqlite3_bind_int(insert_hole_statement, 4, self.whiteYard);
	sqlite3_bind_int(insert_hole_statement, 5, self.blackYard);
	sqlite3_bind_int(insert_hole_statement, 6, self.blueYard);
	sqlite3_bind_int(insert_hole_statement, 7, self.orangeYard);
	sqlite3_bind_int(insert_hole_statement, 8, self.hcp);
	sqlite3_bind_double(insert_hole_statement, 9, self.longitude);
	sqlite3_bind_double(insert_hole_statement, 10, self.latitude);
	sqlite3_bind_int(insert_hole_statement, 11, self.extraYard);
	sqlite3_bind_int(insert_hole_statement, 12, self.bool1);
	sqlite3_bind_int(insert_hole_statement, 13, self.bool2);
	sqlite3_bind_int(insert_hole_statement, 14, self.holeType);
	sqlite3_bind_double(insert_hole_statement, 15, self.teeLongitude);
	sqlite3_bind_double(insert_hole_statement, 16, self.teeLatitude);
	sqlite3_bind_double(insert_hole_statement, 17, self.frontLongitude);
	sqlite3_bind_double(insert_hole_statement, 18, self.frontLatitude);
	sqlite3_bind_double(insert_hole_statement, 19, self.backLongitude);
	sqlite3_bind_double(insert_hole_statement, 20, self.backLatitude);
	
    int success = sqlite3_step(insert_hole_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_hole_statement);

	if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    }
	
}




// Creates the object with primary key and courseName is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db hole:(NSInteger)num {
    if (self = [super init]) {
        database = db;
        courseID = pk;
        holeID = num;
		[self fromDB];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)deleteFromDatabase {
    // Compile the delete statement if needed.
    if (delete_hole_statement == nil) {
        const char *sql = "DELETE FROM coursehole WHERE courseID=? and holeID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_hole_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prewhitePare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_hole_statement, 1, self.courseID);
    sqlite3_bind_int(delete_hole_statement, 2, self.holeID);
    // Execute the query.
    int success = sqlite3_step(delete_hole_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_hole_statement);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
}

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)fromDB {
	// Compile the query for retrieving Score data. See insertNewScoreIntoDatabase: for more detail.
	if (hydrate_hole_statement == nil) {
		// Note the '?' at the end of the query. This is a whiteParameter which can be replaced by a bound variable.
		// This is a great way to optimize because frequently used queries can be compiled once, then with each
		// use new variable values can be bound to placeholders.
		const char *sql = "SELECT * FROM coursehole WHERE courseID=? and holeID=?";
		if (sqlite3_prepare_v2(database, sql, -1, &hydrate_hole_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prewhitePare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_int(hydrate_hole_statement, 1, courseID);
	sqlite3_bind_int(hydrate_hole_statement, 2, holeID);
	int success = sqlite3_step(hydrate_hole_statement);
	if ( success == SQLITE_ROW) {
		self.whitePar = sqlite3_column_int(hydrate_hole_statement, 2);
		self.whiteYard = sqlite3_column_int(hydrate_hole_statement, 3);
		self.blackYard = sqlite3_column_int(hydrate_hole_statement, 4);
		self.blueYard = sqlite3_column_int(hydrate_hole_statement, 5);
		self.orangeYard = sqlite3_column_int(hydrate_hole_statement, 6);
		self.hcp = sqlite3_column_int(hydrate_hole_statement, 7);
		self.longitude = sqlite3_column_double(hydrate_hole_statement, 8);
		self.latitude = sqlite3_column_double(hydrate_hole_statement, 9);
		self.extraYard = sqlite3_column_int(hydrate_hole_statement, 10);
		self.bool1 = sqlite3_column_int(hydrate_hole_statement, 11);
		self.bool2 = sqlite3_column_int(hydrate_hole_statement, 12);
		self.holeType = sqlite3_column_int(hydrate_hole_statement, 13);
		self.teeLongitude = sqlite3_column_double(hydrate_hole_statement, 14);
		self.teeLatitude = sqlite3_column_double(hydrate_hole_statement, 15);
		self.frontLongitude = sqlite3_column_double(hydrate_hole_statement, 16);
		self.frontLatitude = sqlite3_column_double(hydrate_hole_statement, 17);
		self.backLongitude = sqlite3_column_double(hydrate_hole_statement, 18);
		self.backLatitude = sqlite3_column_double(hydrate_hole_statement, 19);
		// Reset the statement for future reuse.
	} else {
		self.whitePar = kInitialParValue;
		self.blackYard = kInitialYardValue;
		self.whiteYard = kInitialYardValue;
		self.blueYard = kInitialYardValue;
		self.orangeYard = kInitialYardValue;
		self.hcp = 0;
		self.longitude = 0;
		self.latitude = 0;
		self.extraYard = 0;
		self.bool1 = 0;
		self.bool2 = 0;
		self.holeType = 0;
		self.teeLongitude = 0;
		self.teeLatitude = 0;
		self.frontLongitude = 0;
		self.frontLatitude = 0;
		self.backLongitude = 0;
		self.backLatitude = 0;
		[self insertNewIntoDatabase:database];
	}
	sqlite3_reset(hydrate_hole_statement);
}

// Flushes all but the primary key and courseName out to the database.
- (void)toDB {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (dehydrate_hole_statement == nil) {
           const char *sql = "UPDATE coursehole SET whitePar=?, whiteYard=?, blackYard=?, blueYard=?, orangeYard=?, hcp=?, longitude=?, latitude=?, extraYard=?, bool1=?, bool2=?, holeType=?, teeLongitude=?, teeLatitude=?,frontLongitude=?, frontLatitude=?, backLongitude=?, backLatitude=? where courseID=? and holeID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_hole_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prewhitePare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
		// Bind the primary key variable.
	sqlite3_bind_int(dehydrate_hole_statement, 1, self.whitePar);
	sqlite3_bind_int(dehydrate_hole_statement, 2, self.whiteYard);
	sqlite3_bind_int(dehydrate_hole_statement, 3, self.blackYard);
	sqlite3_bind_int(dehydrate_hole_statement, 4, self.blueYard);
	sqlite3_bind_int(dehydrate_hole_statement, 5, self.orangeYard);
	sqlite3_bind_int(dehydrate_hole_statement, 6, self.hcp);
	sqlite3_bind_double(dehydrate_hole_statement, 7, self.longitude);
	sqlite3_bind_double(dehydrate_hole_statement, 8, self.latitude);
	sqlite3_bind_int(dehydrate_hole_statement, 9, self.extraYard);
	sqlite3_bind_int(dehydrate_hole_statement, 10, self.bool1);
	sqlite3_bind_int(dehydrate_hole_statement, 11, self.bool2);
	sqlite3_bind_int(dehydrate_hole_statement, 12, self.holeType);
	sqlite3_bind_double(dehydrate_hole_statement, 13, self.teeLongitude);
	sqlite3_bind_double(dehydrate_hole_statement, 14, self.teeLatitude);
	sqlite3_bind_double(dehydrate_hole_statement, 15, self.frontLongitude);
	sqlite3_bind_double(dehydrate_hole_statement, 16, self.frontLatitude);
	sqlite3_bind_double(dehydrate_hole_statement, 17, self.backLongitude);
	sqlite3_bind_double(dehydrate_hole_statement, 18, self.backLatitude);
	sqlite3_bind_int(dehydrate_hole_statement, 19, self.courseID);
		sqlite3_bind_int(dehydrate_hole_statement, 20, self.holeID);
        // Execute the query.
        int success = sqlite3_step(dehydrate_hole_statement);
        // Reset the query for the next use.
        sqlite3_reset(dehydrate_hole_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
}


// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_hole_statement) sqlite3_finalize(insert_hole_statement);
    if (retrieve_hole_statement) sqlite3_finalize(retrieve_hole_statement);
    if (init_hole_statement) sqlite3_finalize(init_hole_statement);
    if (delete_hole_statement) sqlite3_finalize(delete_hole_statement);
    if (hydrate_hole_statement) sqlite3_finalize(hydrate_hole_statement);
    if (dehydrate_hole_statement) sqlite3_finalize(dehydrate_hole_statement);
}

@end

