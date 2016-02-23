//
//  Score.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/18/08.
//  lastDate 2008 JAJSoftware. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "CourseHoleData.h"

@interface Course : NSObject {
    // Opaque reference to the underlying database.
    sqlite3 *database;
    // Primary key in the database.
    NSInteger primaryKey;
    // Attributes.
    NSString *courseName;
    NSDate *lastDate;
    NSString *courseData;
	NSInteger holeNumber;
	NSInteger sr;
	NSInteger cr;
	CourseHoleData		*curHole;
	NSInteger whiteSlope;
	NSInteger blackSlope;
	NSInteger blueSlope;
	NSInteger orangeSlope;
	NSInteger extraSlope;
	double whiteRate;
	double blackRate;
	double blueRate;
	double orangeRate;
	double extraRate;
	NSInteger bool1;
	NSInteger bool2;
    NSString *courseAddress;
    NSString *courseCity;
    NSString *courseState;
    NSString *courseCountry;
    NSString *coursePhone;
    NSString *courseWebsite;
    NSString *courseZipcode;
}

// Property exposure for primary key and other attributes. The primary key is 'assign' because it is not an object, 
// nonatomic because there is no need for concurrent access, and readonly because it cannot be changed without 
// corrupting the database.
@property (assign, nonatomic, readonly) NSInteger primaryKey;
// The remaining attributes are copied rather than retained because they are value objects.
@property (copy, nonatomic) NSString *courseName;
@property (copy, nonatomic) NSDate *lastDate;
@property (copy, nonatomic) NSString *courseData;
@property (assign, nonatomic) NSInteger holeNumber;
@property (assign, nonatomic) NSInteger sr;
@property (assign, nonatomic) NSInteger cr;
@property (copy, nonatomic) CourseHoleData		*curHole;
@property (assign, nonatomic) NSInteger whiteSlope;
@property (assign, nonatomic) NSInteger blackSlope;
@property (assign, nonatomic) NSInteger blueSlope;
@property (assign, nonatomic) NSInteger orangeSlope;
@property (assign, nonatomic) NSInteger extraSlope;
@property (assign, nonatomic) double whiteRate;
@property (assign, nonatomic) double blackRate;
@property (assign, nonatomic) double blueRate;
@property (assign, nonatomic) double orangeRate;
@property (assign, nonatomic) double extraRate;
@property (assign, nonatomic) NSInteger bool1;
@property (assign, nonatomic) NSInteger bool2;
@property (copy, nonatomic) NSString *courseAddress;
@property (copy, nonatomic) NSString *courseCity;
@property (copy, nonatomic) NSString *courseState;
@property (copy, nonatomic) NSString *courseCountry;
@property (copy, nonatomic) NSString *coursePhone;
@property (copy, nonatomic) NSString *courseWebsite;
@property (copy, nonatomic) NSString *courseZipcode;

// Inserts a new row in the database to be used for a new Score object.
+ (NSInteger)insertNewCourseIntoDatabase:(sqlite3 *)database;
// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;
+ (NSInteger)retrieveCourse:(sqlite3 *)database name:(NSString *) what;
+ (NSMutableArray *)retrieveAllCourses:(sqlite3 *)database;
+(id)searchCoursesFromInternet:(NSString *)searchText;

//-(void)initializeHoles:(sqlite3 *)db;

// Creates the object with primary key and courseName is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)fromDB;
// Flushes all but the primary key and courseName out to the database.
- (void)toDB;
// Remove the Score complete from the database. In memory deletion to follow...
- (BOOL)deleteFromDatabase;
-(NSInteger)upload;
+(NSString *)urlEncodeValue:(NSString *)str;
- (BOOL)worthWebUpload;

- (BOOL)isEqual:(id)anObject;


@end

