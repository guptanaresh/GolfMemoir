//
//  Score.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/18/08.
//  lastDate 2008 JAJSoftware. All rights reserved.
//

#import "Course.h"
#import "CourseHoleData.h"
#import "Reachability.h"
#import "Constants.h"

// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *retrieve_statement = nil;
static sqlite3_stmt *retrieve_all_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *delete_score_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;



@implementation Course

@synthesize curHole;
@synthesize primaryKey;
@synthesize courseName;
@synthesize lastDate;
@synthesize courseData;
@synthesize sr;
@synthesize cr;
@synthesize whiteSlope;
@synthesize blackSlope;
@synthesize blueSlope;
@synthesize orangeSlope;
@synthesize extraSlope;
@synthesize whiteRate;
@synthesize blackRate;
@synthesize blueRate;
@synthesize orangeRate;
@synthesize extraRate;
@synthesize bool1;
@synthesize bool2;
@synthesize courseAddress;
@synthesize courseCity;
@synthesize courseState;
@synthesize courseCountry;
@synthesize coursePhone;
@synthesize courseWebsite, courseZipcode;

// Creates a new empty Score record in the database. The primary key is returned, presumably to be used to alloc/init 
// a new Score object. This method is a class method - it can be called without involving an instance of the class.
+ (NSInteger)insertNewCourseIntoDatabase:(sqlite3 *)database {
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO course (courseName) VALUES('')";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
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
+ (NSInteger)retrieveCourse:(sqlite3 *)database name:(NSString *) what{
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (retrieve_statement == nil) {
		static char *sql = "SELECT pk FROM course WHERE courseName=?";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	sqlite3_bind_text(retrieve_statement, 1, [what UTF8String], -1, SQLITE_TRANSIENT);
    int success = sqlite3_step(retrieve_statement);
	NSInteger	pk;
	if (success== SQLITE_ROW) {
		pk = sqlite3_column_int(retrieve_statement, 0);
	} else {
		pk = -1;
	}
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(retrieve_statement);
    return pk;
}


+ (NSMutableArray *)retrieveAllCourses:(sqlite3 *)database {
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed.
    if (retrieve_all_statement == nil) {
		static char *sql = "SELECT * FROM course ORDER BY `courseName`";
        if (sqlite3_prepare_v2(database, sql, -1, &retrieve_all_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
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
		Course *aScore = [[Course alloc] initWithPrimaryKey:primaryKey database:database];
		[aScore fromDB];
		[scoreArray addObject:aScore];
		[aScore release];
	}
	
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(retrieve_all_statement);
    return scoreArray;
}


// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (retrieve_statement) sqlite3_finalize(retrieve_statement);
    if (retrieve_all_statement) sqlite3_finalize(retrieve_all_statement);
    if (init_statement) sqlite3_finalize(init_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (delete_score_statement) sqlite3_finalize(delete_score_statement);
    if (hydrate_statement) sqlite3_finalize(hydrate_statement);
    if (dehydrate_statement) sqlite3_finalize(dehydrate_statement);
}

// Creates the object with primary key and courseName is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
    if (self = [super init]) {
        primaryKey = pk;
        database = db;
		curHole=nil;
		[self fromDB];
    }
    return self;
}

- (void)dealloc {
    [curHole release];
    [super dealloc];
}

- (BOOL)deleteFromDatabase {
	BOOL returnVal = TRUE;
    // Compile the delete statement if needed.
    if (delete_score_statement == nil) {
        char *sql = "select * FROM score WHERE courseID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_score_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_score_statement, 1, primaryKey);
    int isuccess = sqlite3_step(delete_score_statement);
    sqlite3_reset(delete_score_statement);

	if (isuccess == SQLITE_ROW) {
		returnVal = FALSE;
	}
	else{

	
		for(NSInteger hole=1; hole <=18 ; hole +=1){
			self.holeNumber = hole;
			[curHole deleteFromDatabase];
		}
		// Compile the delete statement if needed.
		if (delete_statement == nil) {
			const char *sql = "DELETE FROM course WHERE pk=?";
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
		// Handle errors.
		if (success != SQLITE_DONE) {
			NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	return returnVal;
}

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)fromDB {
    // Check if action is necessary.
    // Compile the hydration statement, if needed.
    if (hydrate_statement == nil) {
        const char *sql = "SELECT * FROM course WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &hydrate_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(hydrate_statement, 1, primaryKey);
    // Execute the query.
    int success =sqlite3_step(hydrate_statement);
    if (success == SQLITE_ROW) {
        char *str = (char *)sqlite3_column_text(hydrate_statement, 1);
        self.courseName = (str) ? [NSString stringWithUTF8String:str] : @"";
        str = (char *)sqlite3_column_text(hydrate_statement, 2);
        self.courseData = (str) ? [NSString stringWithUTF8String:str] : @"";
        self.lastDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(hydrate_statement, 3)];
        self.holeNumber = (NSInteger)sqlite3_column_int(hydrate_statement, 4);
        self.whiteSlope = (NSInteger)sqlite3_column_int(hydrate_statement, 7);
        self.blackSlope = (NSInteger)sqlite3_column_int(hydrate_statement, 8);
        self.blueSlope = (NSInteger)sqlite3_column_int(hydrate_statement, 9);
        self.orangeSlope = (NSInteger)sqlite3_column_int(hydrate_statement, 10);
        self.whiteRate = (double)sqlite3_column_double(hydrate_statement, 12);
        self.blackRate = (double)sqlite3_column_double(hydrate_statement, 13);
        self.blueRate = (double)sqlite3_column_double(hydrate_statement, 14);
        self.orangeRate = (double)sqlite3_column_double(hydrate_statement, 15);
		str = (char *)sqlite3_column_text(hydrate_statement, 19);
        self.courseAddress = (str) ? [NSString stringWithUTF8String:str] : @"";
		str = (char *)sqlite3_column_text(hydrate_statement, 20);
        self.courseCity = (str) ? [NSString stringWithUTF8String:str] : @"";
		str = (char *)sqlite3_column_text(hydrate_statement, 21);
        self.courseState = (str) ? [NSString stringWithUTF8String:str] : @"";
		str = (char *)sqlite3_column_text(hydrate_statement, 22);
        self.courseCountry = (str) ? [NSString stringWithUTF8String:str] : @"";
		str = (char *)sqlite3_column_text(hydrate_statement, 23);
        self.coursePhone = (str) ? [NSString stringWithUTF8String:str] : @"";
		str = (char *)sqlite3_column_text(hydrate_statement, 24);
        self.courseWebsite = (str) ? [NSString stringWithUTF8String:str] : @"";
		str = (char *)sqlite3_column_text(hydrate_statement, 25);
        self.courseZipcode = (str) ? [NSString stringWithUTF8String:str] : @"";
 } else {
        // The query did not return 
        self.courseData = @"Unknown";
        self.lastDate = [NSDate date];
        self.holeNumber = (NSInteger)1;
    }
	// Reset the query for the next use.
	sqlite3_reset(hydrate_statement);
	
	if(curHole !=nil)
		[curHole release];
	curHole=[[CourseHoleData alloc] initWithPrimaryKey:self.primaryKey database:database hole:holeNumber];
}

// Flushes all but the primary key and courseName out to the database.
- (void)toDB {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (dehydrate_statement == nil) {
            const char *sql = "UPDATE course SET courseName=?, courseData=?, lastDate=?, holeNumber=?, courseAddress=?, courseCity=?, courseState=?, courseCountry=?, coursePhone=?, courseWebsite=?, courseZipcode=?, whiteSlope=?, blackSlope=?, blueSlope=?, orangeSlope=?, whiteRate=?, blackRate=?, blueRate=?, orangeRate=? WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &dehydrate_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
        sqlite3_bind_text(dehydrate_statement, 1, [courseName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(dehydrate_statement, 2, [courseData UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(dehydrate_statement, 3, [lastDate timeIntervalSince1970]);
        sqlite3_bind_int(dehydrate_statement, 4, holeNumber);
		sqlite3_bind_text(dehydrate_statement, 5, [courseAddress UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement, 6, [courseCity UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement, 7, [courseState UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement, 8, [courseCountry UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(dehydrate_statement, 9, [coursePhone UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dehydrate_statement, 10, [courseWebsite UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(dehydrate_statement, 11, [courseZipcode UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(dehydrate_statement, 12, whiteSlope);
	sqlite3_bind_int(dehydrate_statement, 13, blackSlope);
	sqlite3_bind_int(dehydrate_statement, 14, blueSlope);
	sqlite3_bind_int(dehydrate_statement, 15, orangeSlope);
	sqlite3_bind_double(dehydrate_statement, 16, whiteRate);
	sqlite3_bind_double(dehydrate_statement, 17, blackRate);
	sqlite3_bind_double(dehydrate_statement, 18, blueRate);
	sqlite3_bind_double(dehydrate_statement, 19, orangeRate);
        sqlite3_bind_int(dehydrate_statement, 20, primaryKey);
        // Execute the query.
        int success = sqlite3_step(dehydrate_statement);
        // Reset the query for the next use.
        sqlite3_reset(dehydrate_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
		[curHole toDB];
}


- (NSInteger)holeNumber {
    return holeNumber;
}

- (void)setHoleNumber:(NSInteger)aNum {
	if(holeNumber != aNum){
		holeNumber = aNum;
		curHole.holeID=aNum;
		[curHole fromDB];
	}
}

-(NSInteger)upload{
	if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Can't upload course information because there is no internet connection available."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else{
		NSURL *url = [NSURL URLWithString:@"http://www.golfmemoir.com/course_upload.php"]; 
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
		[request setHTTPMethod:@"POST"];
		
		NSMutableString *post = [NSMutableString stringWithFormat:@"courseName=%@&courseAddress=%@&courseCity=%@&courseState=%@&courseCountry=%@&coursePhone=%@&courseWebsite=%@&courseZipcode=%@", 
								 [Course urlEncodeValue:self.courseName],
								 [Course urlEncodeValue:self.courseAddress],
								 [Course urlEncodeValue:self.courseCity],
								 [Course urlEncodeValue:self.courseState],
								 [Course urlEncodeValue:self.courseCountry],
								 [Course urlEncodeValue:self.coursePhone],
								 [Course urlEncodeValue:self.courseWebsite],
								 [Course urlEncodeValue:self.courseZipcode]
								 ];
		[post appendFormat:@"&whiteSlope=%i&blackSlope=%i&blueSlope=%i&orangeSlope=%i&whiteRate=%f&blackRate=%f&blueRate=%f&orangeRate=%f",
							 self.whiteSlope,
							 self.blackSlope,
							 self.blueSlope,
							 self.orangeSlope,
							 self.whiteRate,
							 self.blackRate,
							 self.blueRate,
							 self.orangeRate
							];
		NSInteger curHoleNumber=self.holeNumber;
		for(int i=0; i <18; i++){
			self.holeNumber=i+1;
			[post appendFormat:@"&par[%i]=%i",i,self.curHole.whitePar];
			[post appendFormat:@"&yardwh[%i]=%i",i,self.curHole.whiteYard];
			[post appendFormat:@"&yardbk[%i]=%i",i,self.curHole.blackYard];
			[post appendFormat:@"&yardbl[%i]=%i",i,self.curHole.blueYard];
			[post appendFormat:@"&yardor[%i]=%i",i,self.curHole.orangeYard];
			[post appendFormat:@"&hcp[%i]=%i",i,self.curHole.hcp];
			[post appendFormat:@"&holeType[%i]=%i",i,self.curHole.holeType];
			[post appendFormat:@"&latitude[%i]=%f",i,self.curHole.latitude];
			[post appendFormat:@"&longitude[%i]=%f",i,self.curHole.longitude];
			[post appendFormat:@"&teeLongitude[%i]=%f",i,self.curHole.teeLongitude];
			[post appendFormat:@"&teeLatitude[%i]=%f",i,self.curHole.teeLatitude];
			[post appendFormat:@"&frontLongitude[%i]=%f",i,self.curHole.frontLongitude];
			[post appendFormat:@"&frontLatitude[%i]=%f",i,self.curHole.frontLatitude];
			[post appendFormat:@"&backLongitude[%i]=%f",i,self.curHole.backLongitude];
			[post appendFormat:@"&backLatitude[%i]=%f",i,self.curHole.backLatitude];
		}
		
		self.holeNumber=curHoleNumber;
		
//		NSLog(post);
		
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
			return 0;
		} else {
			NSString *str = [[NSString alloc] initWithData:searchData encoding:NSASCIIStringEncoding];
			NSLog(@"%@", str);
			return [str intValue];
		}
	}
	return 0;
}	

+(id)searchCoursesFromInternet:(NSString *)searchText
{
	NSString *tx= [NSString stringWithFormat:@"http://www.golfmemoir.com/courselist_download.php?search=%@", [Course urlEncodeValue:searchText]];

	NSURL *url = [NSURL URLWithString:tx]; 
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLResponse *response;
	NSError *error;
	NSData *plistData;
	plistData = [NSURLConnection sendSynchronousRequest:request
									  returningResponse:&response error:&error];

	NSString *str = [[NSString alloc] initWithData:plistData encoding:NSASCIIStringEncoding];
	NSLog(@"%@", str);

	// parse the HTTP response into a plist
	NSPropertyListFormat format;
	id plist;
	NSString *errorStr;
	plist = [NSPropertyListSerialization propertyListFromData:plistData
											 mutabilityOption:NSPropertyListImmutable
													   format:&format
											 errorDescription:&errorStr];
	if(!plist){
		NSLog(@"%@", errorStr);
		[error release];
	}
	return plist;
}
+ (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

- (BOOL)worthWebUpload{
	NSInteger curHoleNumber=self.holeNumber;
	NSInteger parTotal=0;
	NSInteger whiteYardTotal=0;
	NSInteger blackYardTotal=0;
	NSInteger blueYardTotal=0;
	NSInteger orangeYardTotal=0;
	
	for(int i=0; i <18; i++){
		self.holeNumber=i+1;
		if(self.curHole.whitePar > kInitialParValue)
			parTotal++;
		if(self.curHole.blackYard > kInitialYardValue)
			blackYardTotal++;
		if(self.curHole.blueYard > kInitialYardValue)
			blueYardTotal++;
		if(self.curHole.whiteYard > kInitialYardValue)
			whiteYardTotal++;
		if(self.curHole.orangeYard > kInitialYardValue)
			orangeYardTotal++;
	}
	
	self.holeNumber=curHoleNumber;
	
	if((parTotal > 4) || (blackYardTotal > 4) || (blueYardTotal > 4) || (whiteYardTotal > 4) || (orangeYardTotal > 4))
		return TRUE;
	else
		return FALSE;
}

- (BOOL)isEqual:(id)anObject{
	Course *crs=(Course *)anObject;
	if(crs != nil && crs.primaryKey == self.primaryKey)
		return TRUE;
	else
		return FALSE;
}

@end

