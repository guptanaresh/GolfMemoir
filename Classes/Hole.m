//
//  Score.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/18/08.
//  playDate 2008 JAJSoftware. All rights reserved.
//

#import "Hole.h"
#import "Constants.h"

// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_hole_statement = nil;
static sqlite3_stmt *insert_stroke_statement = nil;
static sqlite3_stmt *update_stroke_statement = nil;
static sqlite3_stmt *retrieve_stroke_statement = nil;
static sqlite3_stmt *delete_stroke_statement = nil;
static sqlite3_stmt *retrieve_hole_statement = nil;
static sqlite3_stmt *init_hole_statement = nil;
static sqlite3_stmt *delete_hole_statement = nil;
static sqlite3_stmt *hydrate_hole_statement = nil;
static sqlite3_stmt *dehydrate_hole_statement = nil;


@implementation Hole
@synthesize distance, longitude, latitude, putt;
@synthesize strokeNum2, strokeNum3, strokeNum4;


// Creates a new empty Score record in the database. The primary key is returned, presumably to be used to alloc/init 
// a new Score object. This method is a class method - it can be called without involving an instance of the class.
-(void)insertNewIntoDatabase:(sqlite3 *)db {
		if (insert_hole_statement == nil) {
        static char *sql = "INSERT INTO hole (scoreID, holeID, strokeNum, strokeNum2, strokeNum3, strokeNum4) Values (?, ?, ?,?,?,?)";
        if (sqlite3_prepare_v2(db, sql, -1, &insert_hole_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
        }
		}
	sqlite3_bind_int(insert_hole_statement, 1, self.scoreID);
	sqlite3_bind_int(insert_hole_statement, 2, self.holeID);
	sqlite3_bind_int(insert_hole_statement, 3, self.strokeNum);
	sqlite3_bind_int(insert_hole_statement, 4, self.strokeNum2);
	sqlite3_bind_int(insert_hole_statement, 5, self.strokeNum3);
	sqlite3_bind_int(insert_hole_statement, 6, self.strokeNum4);

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
        scoreID = pk;
        holeID = num;
        strokeNum = 0;
        strokeNum2 = 0;
        strokeNum3 = 0;
        strokeNum4 = 0;
        distance = 0;
		longitude=0;
		latitude=0;
		putt=0;
		[self fromDB];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)deleteFromDatabase {
    // Compile the delete statement if needed.
	[self deleteStrokes];
    if (delete_hole_statement == nil) {
        const char *sql = "DELETE FROM hole WHERE scoreID=? and holeID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_hole_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_hole_statement, 1, self.scoreID);
    sqlite3_bind_int(delete_hole_statement, 2, self.holeID);
    // Execute the query.
    sqlite3_step(delete_hole_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_hole_statement);
}

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)fromDB {
	// Compile the query for retrieving Score data. See insertNewScoreIntoDatabase: for more detail.
	if (hydrate_hole_statement == nil) {
		// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
		// This is a great way to optimize because frequently used queries can be compiled once, then with each
		// use new variable values can be bound to placeholders.
		const char *sql = "SELECT * FROM hole WHERE scoreID=? and holeID=?";
		if (sqlite3_prepare_v2(database, sql, -1, &hydrate_hole_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_bind_int(hydrate_hole_statement, 1, scoreID);
	sqlite3_bind_int(hydrate_hole_statement, 2, holeID);
	int success = sqlite3_step(hydrate_hole_statement);
	if ( success == SQLITE_ROW) {
		self.strokeNum = sqlite3_column_int(hydrate_hole_statement, 2);
		self.strokeNum2 = sqlite3_column_int(hydrate_hole_statement, 3);
		self.strokeNum3 = sqlite3_column_int(hydrate_hole_statement, 4);
		self.strokeNum4 = sqlite3_column_int(hydrate_hole_statement, 5);
		// Reset the statement for future reuse.
	} else {
		self.strokeNum = 0;
        strokeNum2 = 0;
        strokeNum3 = 0;
        strokeNum4 = 0;
        distance = 0;
		longitude=0;
		latitude=0;
		putt=0;
		[self insertNewIntoDatabase:database];
	}
	sqlite3_reset(hydrate_hole_statement);
}

// Flushes all but the primary key and courseName out to the database.
- (void)toDB {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (dehydrate_hole_statement == nil) {
           const char *sql = "UPDATE hole SET strokeNum=?, strokeNum2=? , strokeNum3=?, strokeNum4=? where scoreID=? and holeID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_hole_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
		// Bind the primary key variable.
		sqlite3_bind_int(dehydrate_hole_statement, 1, self.strokeNum);
		sqlite3_bind_int(dehydrate_hole_statement, 2, self.strokeNum2);
		sqlite3_bind_int(dehydrate_hole_statement, 3, self.strokeNum3);
		sqlite3_bind_int(dehydrate_hole_statement, 4, self.strokeNum4);
		sqlite3_bind_int(dehydrate_hole_statement, 5, self.scoreID);
		sqlite3_bind_int(dehydrate_hole_statement, 6, self.holeID);
        // Execute the query.
        int success = sqlite3_step(dehydrate_hole_statement);
        // Reset the query for the next use.
        sqlite3_reset(dehydrate_hole_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
}

- (BOOL)readStroke {
	BOOL found = true;
	if (retrieve_stroke_statement == nil) {
        static char *sql = "SELECT * FROM stroke WHERE scoreID=? and holeID=? and strokeNum=?";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_stroke_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
	}
	sqlite3_bind_int(retrieve_stroke_statement, 1, self.scoreID);
	sqlite3_bind_int(retrieve_stroke_statement, 2, self.holeID);
	sqlite3_bind_int(retrieve_stroke_statement, 3, self.strokeNum);
	
    int success = sqlite3_step(retrieve_stroke_statement);
   	if ( success == SQLITE_ROW) {
		self.distance = sqlite3_column_int(retrieve_stroke_statement, 3);
		self.longitude = sqlite3_column_double(retrieve_stroke_statement, 4);
		self.latitude = sqlite3_column_double(retrieve_stroke_statement, 5);
		self.putt = sqlite3_column_int(retrieve_stroke_statement, 6);
	} else {
/*
		distance = 0;
		longitude=0;
		latitude=0;
		putt=0;
*/
		found = false;
	}
		
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(retrieve_stroke_statement);
	return found;
}
- (void)saveStroke {
	if (retrieve_stroke_statement == nil) {
        static char *sql = "SELECT * FROM stroke WHERE scoreID=? and holeID=? and strokeNum=?";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_stroke_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
	}
	sqlite3_bind_int(retrieve_stroke_statement, 1, self.scoreID);
	sqlite3_bind_int(retrieve_stroke_statement, 2, self.holeID);
	sqlite3_bind_int(retrieve_stroke_statement, 3, self.strokeNum);
	
    int success = sqlite3_step(retrieve_stroke_statement);
   	if ( success == SQLITE_ROW) {
		if (update_stroke_statement == nil) {
			static char *sql = "UPDATE stroke SET distance=?, longitude=?, latitude=?, putt=? where scoreID=? and holeID=? and strokeNum=?";
			if (sqlite3_prepare_v2(database, sql, -1, &update_stroke_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		sqlite3_bind_int(update_stroke_statement, 1, self.distance);
		sqlite3_bind_double(update_stroke_statement, 2, self.longitude);
		sqlite3_bind_double(update_stroke_statement, 3, self.latitude);
		sqlite3_bind_int(update_stroke_statement, 4, self.putt);
		sqlite3_bind_int(update_stroke_statement, 5, self.scoreID);
		sqlite3_bind_int(update_stroke_statement, 6, self.holeID);
		sqlite3_bind_int(update_stroke_statement, 7, self.strokeNum);
		
		int success = sqlite3_step(update_stroke_statement);
		// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
		sqlite3_reset(update_stroke_statement);
		
		if (success == SQLITE_ERROR) {
			NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
		}
	} else {
		if (insert_stroke_statement == nil) {
			static char *sql = "INSERT INTO stroke (scoreID, holeID, strokeNum, distance, longitude, latitude, putt) Values (?, ?, ?, ?, ?, ?, ?)";
			if (sqlite3_prepare_v2(database, sql, -1, &insert_stroke_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		sqlite3_bind_int(insert_stroke_statement, 1, self.scoreID);
		sqlite3_bind_int(insert_stroke_statement, 2, self.holeID);
		sqlite3_bind_int(insert_stroke_statement, 3, self.strokeNum);
		sqlite3_bind_int(insert_stroke_statement, 4, self.distance);
		sqlite3_bind_double(insert_stroke_statement, 5, self.longitude);
		sqlite3_bind_double(insert_stroke_statement, 6, self.latitude);
		sqlite3_bind_int(insert_stroke_statement, 7, self.putt);
		
		int success = sqlite3_step(insert_stroke_statement);
		// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
		sqlite3_reset(insert_stroke_statement);
		
		if (success == SQLITE_ERROR) {
			NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
		}
	}
    sqlite3_reset(retrieve_stroke_statement);
	
}

- (void)deleteStrokes {
	if (delete_stroke_statement == nil) {
        const char *sql = "DELETE FROM stroke WHERE scoreID=? and holeID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_stroke_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
	}
	sqlite3_bind_int(delete_stroke_statement, 1, self.scoreID);
	sqlite3_bind_int(delete_stroke_statement, 2, self.holeID);
	
    sqlite3_step(delete_stroke_statement);
	// Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(delete_stroke_statement);
	
}

#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

- (NSInteger)scoreID {
    return scoreID;
}


- (void)setScoreID:(NSInteger)aID {
    scoreID = aID;
}

- (NSInteger)holeID {
    return holeID;
}


- (void)setHoleID:(NSInteger)aID {
    holeID = aID;
}

- (NSInteger)strokeNum {
    return strokeNum;
}


- (void)setStrokeNum:(NSInteger)aID {
    strokeNum = aID;
}

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_hole_statement) sqlite3_finalize(insert_hole_statement);
    if (retrieve_hole_statement) sqlite3_finalize(retrieve_hole_statement);
    if (init_hole_statement) sqlite3_finalize(init_hole_statement);
    if (delete_hole_statement) sqlite3_finalize(delete_hole_statement);
    if (hydrate_hole_statement) sqlite3_finalize(hydrate_hole_statement);
    if (dehydrate_hole_statement) sqlite3_finalize(dehydrate_hole_statement);
    if (insert_stroke_statement) sqlite3_finalize(insert_stroke_statement);
    if (retrieve_stroke_statement) sqlite3_finalize(retrieve_stroke_statement);
    if (delete_stroke_statement) sqlite3_finalize(delete_stroke_statement);
	
}

@end

