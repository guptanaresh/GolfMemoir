//
//  GolfMemoirAppDelegate.h
//  GolfMemoir
//
//  Created by naresh gupta on 5/5/08.
//  Copyright JAJSoftware 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
// This includes the header for the SQLite library.
#import <sqlite3.h>
#import "Score.h"
#import "AppSettings.h"
#import "SettingsViewController.h"
#import "Course.h"
#import "User.h"
#import <CoreLocation/CoreLocation.h>//
#import "FBConnect/FBConnect.h"
#import "PayObserver.h"
#import "BTSessionManager.h"
#import "BTDevicesManager.h"
#import "DataHandler.h"

@interface GolfMemoirAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
    Score *mScore;
    // Opaque reference to the SQLite database.
    sqlite3 *database;
	UINavigationController *firstViewC;
	UINavigationController *secondViewC;
	UINavigationController *thirdViewC;
	UINavigationController *fourthViewC;
	BOOL		restartGame;
	AppSettings *appSettings;
	FBSession *sessionCache;
	PayObserver *pay;
	BTSessionManager *sessionManager;
	DataHandler *dataHandler;
	BTDevicesManager *devicesManager;	
    BTDevice *device2;
    BTDevice *device3;
    BTDevice *device4;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
// Makes the main array of book objects available to other objects in the application.
@property (nonatomic, retain) Score *mScore;
@property (nonatomic, assign) sqlite3 *database;
@property (nonatomic, assign) BOOL restartGame;
@property (nonatomic, retain) AppSettings *appSettings;
@property (nonatomic, retain) FBSession *sessionCache;
@property (nonatomic, retain) PayObserver *pay;
@property (nonatomic, retain) BTSessionManager *sessionManager;
@property (nonatomic, retain) DataHandler *dataHandler;
@property (nonatomic, retain) BTDevicesManager *devicesManager;
@property (assign, nonatomic) BTDevice *device2;
@property (assign, nonatomic) BTDevice *device3;
@property (assign, nonatomic) BTDevice *device4;

-(int)upgradeToVersion2;
-(int)upgradeToVersion4;
-(int)upgradeToVersion5;
-(int)upgradeToVersion6;
-(int)upgradeToVersion7;
@end
