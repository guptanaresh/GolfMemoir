//
//  GolfMemoirAppDelegate.m
//  GolfMemoir
//
//  Created by naresh gupta on 5/5/08.
//  Copyright JAJSoftware 2008. All rights reserved.
//

#import "GolfMemoirAppDelegate.h"
#import "FirstViewController.h"
#import "LoginViewController.h"
#import "GameMainViewController.h"
#import "GameHoleViewController.h"
#import "ListMainViewController.h"
#import "CourseMainViewController.h"
#import "UnlockWebViewController.h"
#import "SettingsViewController.h"
#import "Score.h"
#import "Constants.h"

// Private interface for AppDelegate - internal only methods.
@interface GolfMemoirAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;
@end


@implementation GolfMemoirAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize mScore, database;
@synthesize restartGame, appSettings, sessionCache, pay;
@synthesize sessionManager, devicesManager, dataHandler;
@synthesize device2;
@synthesize device3;
@synthesize device4;




- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // The application ships with a default database in its bundle. If anything in the application
    // bundle is altered, the code sign will fail. We want the database to be editable by users, 
    // so we need to create a copy of it in the application's Documents directory.  

    [self createEditableCopyOfDatabaseIfNeeded];
    // Call internal method to initialize database connection
    [self initializeDatabase];
	
	// only enable this code to create an expired version.
/*
	NSDate *todayDate = [NSDate date];
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:2008];
	[comps setMonth:12];
	[comps setDay:1];
	NSDate *expDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
	[comps release];
	if([expDate compare:todayDate] == NSOrderedAscending){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Expired" message:@"This trial version is expired. Please update to get the latest version."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		return;
	}
*/
	
	NSInteger primaryKey = [Score retrieveOpenGameDatabase:database] ;
	UIViewController *startController = [[GameMainViewController alloc] init];	
	firstViewC = [[UINavigationController alloc] initWithRootViewController:startController];
	if(primaryKey != -1){
		startController = [[GameHoleViewController alloc] init];	
		[firstViewC pushViewController:startController animated:YES];
	}
	firstViewC.title=NSLocalizedString(@"Holes", @"");
	firstViewC.tabBarItem.image=[UIImage imageNamed:@"Holes.png"];
	restartGame=FALSE;
	ListMainViewController *listController = [[ListMainViewController alloc] init];	
	secondViewC = [[UINavigationController alloc] initWithRootViewController:listController];
	secondViewC.tabBarItem.image=[UIImage imageNamed:@"rounds.png"];
	thirdViewC = [[UINavigationController alloc] initWithRootViewController:[[CourseMainViewController alloc] init]];
	thirdViewC.tabBarItem.image=[UIImage imageNamed:@"Courses.png"];
	fourthViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
	//fourthViewC = [[SettingsViewController alloc] init];
	fourthViewC.title=NSLocalizedString(@"Settings", @"");
	fourthViewC.tabBarItem.image=[UIImage imageNamed:@"settings.png"];
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:firstViewC, secondViewC, thirdViewC, fourthViewC, nil];
	//tabBarController.viewControllers = [NSArray arrayWithObjects:firstViewC, secondViewC, thirdViewC, nil];
	tabBarController.delegate=self;
	
    /*
    CGRect navBounds= firstViewC.navigationBar.bounds;
	CGPoint navCenter= firstViewC.navigationBar.center;
	CGRect newrect = CGRectMake(	navBounds.origin.x, navBounds.origin.y, navBounds.size.width, navBounds.size.height+80);
	CGPoint newcenter = CGPointMake(	navCenter.x, navCenter.y+40);
	firstViewC.navigationBar.bounds = newrect;
	firstViewC.navigationBar.center = newcenter;
	*/
    
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
	pay=[[PayObserver alloc] init];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:pay];
	
}

/*
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Out Of Memory" message:@"Please Restart"
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
	
}
*/
/*
 */

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	return TRUE;
	
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}

- (void)dealloc {
	[tabBarController release];
	[window release];
    [mScore release];
	[pay release];
	[super dealloc];
}


- (void)alertOKCancelAction
{
	// open a alert with an OK and cancel button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Policy" message:[kPrivacyPolicy stringByAppendingString:kPrivacyPolicyAccept]
												   delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
	[alert show];
	[alert release];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		appSettings.privacyAccepted = 0;
		//[self applicationWillTerminate:[UIApplication sharedApplication]];
		//[self applicationWillResignActive:[UIApplication sharedApplication]];
		[self applicationWillTerminate:[UIApplication sharedApplication]];
		window.hidden=TRUE;
}
	else
	{
		appSettings.privacyAccepted = 1;
		[appSettings toDB];
	}
}


// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:kDatabaseFile];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (!success)
	{
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDatabaseFile];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
}

// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase {
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kDatabaseFile];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        // Get the primary key for all books.
		appSettings=[[AppSettings alloc] initWithDB:database];
		//version 0 - start
		//version 1 - noop
		//version 2 - second version
		//version 3 - noop
		//version 4 third version
		//version 5 fourth version
		
		if(appSettings.appVersion < 2){
			[self upgradeToVersion2];
		}
		if(appSettings.appVersion < 4){
			[self upgradeToVersion4];
		}
		if(appSettings.appVersion < 5){
			[self upgradeToVersion5];
		}
		if(appSettings.appVersion < 6){
			[self upgradeToVersion6];
		}
		if(appSettings.appVersion < 7){
			[self upgradeToVersion7];
		}
		if(appSettings.appVersion < 8){
			[self upgradeToVersion8];
		}
		if(appSettings.appVersion < 9){
			[self upgradeToVersion9];
		}
		
		
#ifdef PERMIUM_VERSION
		User *myUser=[[User alloc] initWithDB:self.database];
		
		if(myUser.service < PERMIUM_VERSION){
			myUser.service=PERMIUM_VERSION;
			[myUser toDB];
		}
#endif
		
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

-(int)upgradeToVersion2
{
	sqlite3_stmt *statement;
	int	done=SQLITE_DONE;
	char *sql1 = kAppVersion2Upgrade1;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	char *sql2 = kAppVersion2Upgrade2;
	if (sqlite3_prepare_v2(database, sql2, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	char *sql3 = kAppVersion2Upgrade3;
	if (sqlite3_prepare_v2(database, sql3, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	char *sql4 = kAppVersion2Upgrade4;
	if (sqlite3_prepare_v2(database, sql4, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	char *sql5 = kAppVersion2Upgrade5;
	if (sqlite3_prepare_v2(database, sql5, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	char *sql6 = kAppVersion2Upgrade6;
	if (sqlite3_prepare_v2(database, sql6, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	char *sql7 = kAppVersion2Upgrade7;
	if (sqlite3_prepare_v2(database, sql7, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	
	
	if(done == SQLITE_DONE){
		appSettings.appVersion = 2;
		[appSettings toDB];
	}
	return done;
	
}
-(int)upgradeToVersion4
{
	sqlite3_stmt *statement;
	int	done=SQLITE_DONE;
	char *sql1 = kAppVersion4Upgrade1;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	char *sql2 = kAppVersion4Upgrade2;
	if (sqlite3_prepare_v2(database, sql2, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	char *sql3 = kAppVersion4Upgrade3;
	if (sqlite3_prepare_v2(database, sql3, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	char *sql4 = kAppVersion4Upgrade4;
	if (sqlite3_prepare_v2(database, sql4, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	char *sql5 = kAppVersion4Upgrade5;
	if (sqlite3_prepare_v2(database, sql5, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	
	if(done == SQLITE_DONE){
		appSettings.appVersion = 4;
		[appSettings toDB];
	}
	return done;
	
}

-(int)upgradeToVersion5
{
	sqlite3_stmt *statement;
	int	done=SQLITE_DONE;
	char *sql1 = kAppVersion5Upgrade1;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}

	sql1 = kAppVersion5Upgrade2;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}

	sql1 = kAppVersion5Upgrade3;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	sql1 = kAppVersion5Upgrade4;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	sql1 = kAppVersion5Upgrade5;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	sql1 = kAppVersion5Upgrade6;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	sql1 = kAppVersion5Upgrade7;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	sql1 = kAppVersion5Upgrade8;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	sql1 = kAppVersion5Upgrade9;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	
	sql1 = kAppVersion5Upgrade10;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	[appSettings fromDB];
	return done;
	
}

-(int)upgradeToVersion6
{
	sqlite3_stmt *statement;
	int	done=SQLITE_DONE;
	char *sql1 = kAppVersion6Upgrade1;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	
	sql1 = kAppVersion6Upgrade2;
	if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
		done = sqlite3_step(statement);
		sqlite3_finalize(statement);
		if(done != SQLITE_DONE){
			return done;
		}
	}
	
	[appSettings fromDB];
	return done;
	
}

-(int)upgradeToVersion7
{
	sqlite3_stmt *statement;
	int	done=SQLITE_DONE;
	char *sql1 = nil;
	
	for(int i=1; i<=13;i++){
		if(i== 1)
			sql1 = kAppVersion7Upgrade1;
		else if(i==2)
			sql1 = kAppVersion7Upgrade2;
		else if(i==3)
			sql1 = kAppVersion7Upgrade3;
		else if(i==4)
			sql1 = kAppVersion7Upgrade4;
		else if(i==5)
			sql1 = kAppVersion7Upgrade5;
		else if(i==6)
			sql1 = kAppVersion7Upgrade6;
		else if(i==7)
			sql1 = kAppVersion7Upgrade7;
		else if(i==8)
			sql1 = kAppVersion7Upgrade8;
		else if(i==9)
			sql1 = kAppVersion7Upgrade9;
		else if(i==10)
			sql1 = kAppVersion7Upgrade10;
		else if(i==11)
			sql1 = kAppVersion7Upgrade11;
		else if(i==12)
			sql1 = kAppVersion7Upgrade12;
		else if(i==13)
			sql1 = kAppVersion7Upgrade13;
		if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
			done = sqlite3_step(statement);
			sqlite3_finalize(statement);
			if(done != SQLITE_DONE){
				return done;
			}
		}
	}
	
	[appSettings fromDB];
	
	return done;
	
}
-(void)upgradeToVersion8
{
	
	NSMutableArray *scoreList = [Score retrieveAllFinishedScores:database];
	NSUInteger count=[scoreList count];
	for(NSInteger i=count-1; i>=0; i--){
		Score *aScore=[scoreList objectAtIndex:i];
		if(aScore.status==1)
			[aScore finish];
	}
	
	appSettings.appVersion = 8;
	[appSettings toDB];
	
}
-(int)upgradeToVersion9
{
	sqlite3_stmt *statement;
	int	done=SQLITE_DONE;
	char *sql1 = nil;
	
	for(int i=1; i<=2;i++){
		if(i== 1)
			sql1 = kAppVersion9Upgrade1;
		else if(i==2)
			sql1 = kAppVersion9Upgrade2;
		
		if (sqlite3_prepare_v2(database, sql1, -1, &statement, NULL) == SQLITE_OK) {
			done = sqlite3_step(statement);
			sqlite3_finalize(statement);
			if(done != SQLITE_DONE){
				return done;
			}
		}
	}
	
	[appSettings fromDB];
	
	return done;
	
}


// Save all changes to the database, then close it.
- (void)applicationWillTerminate:(UIApplication *)application {
    // Save changes.
    [Score finalizeStatements];
    [Hole finalizeStatements];
    [CourseHoleData finalizeStatements];
    [Course finalizeStatements];
	[AppSettings finalizeStatements];
    // Close the database.
    sqlite3_close(database);
}


@end

