/* weightbot, colors, icoria apps
 Instrument and shark
 transition instrument for ui
 
<A HREF="http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=310459827&mt=8">Email Sent from iPhone Golf Application</A> 
*/





#define kAppVersion 9
#define PERMIUM_VERSION 3
//#define TEST_VERSION
#define kAllowAd TRUE
#define AD_REFRESH_PERIOD 8
#define kAdBottom 412
#define kAdTop 2
#define kAdID1 @"a1490ec3786e764"
#define kAdID2 @"a1490e700c9fea0"
#define kDatabaseFile	@"golfscores.sql"
#define kCustomButtonHeight		40.0
#define kToolbarHeight			40.0

#define kStdButtonWidth 150

//controls resolution of image saved and displayed.
#define kMaxResolution  320


#define kInitialParValue 3
#define kInitialYardValue 0


#define kScoreCardHeaderHeight 20
#define kScoreCardRowHeight 20
#define kStablefordScoreCardRowHeight 55

#define kDriveEnum 0
#define kFairwayEnum 1
#define kPuttEnum 2

#define k18HolesEnum 0
#define kFrontNineEnum 1
#define kBackNineEnum 2

#define kBadMinScore 18

#define kFacebookAppID @"bc97e51f1cac2b40c75a881d0dc3d9ac"
#define kFacebookAppSecret @"600063399df976d5fd584d1bc3154ace"
//#define kFBStoryTemplateID 70695379252
#define kFBStoryTemplateID 124775074252


//service enums
enum {
	kServiceUnlock				= 1 << 0,
	kServiceImageUpload			= 1 << 1
};

#define MY_DISTANCE_PREF_KEY @"meters_pref"
#define MY_DISTANCE_PREF_YD @"Yd"
#define MY_DISTANCE_PREF_YARDS @"Yards"
#define MY_DISTANCE_PREF_METERS @"Meters"
#define MY_DISTANCE_TEXT_YARDS @"Yards:"
#define MY_DISTANCE_TEXT_METERS @"Meters:"
#define MY_DISTANCE_PREF_MT @"Mt"

#define  kEmailURLString @"mailto:?subject=GolfMemoir&body=ScoreCard-http://www.golfmemoir.com/index.php?panel=fromScorelist-%i-%@."
#define  kEmailBodyString @"Click this link for <a href=http://www.golfmemoir.com/index.php?panel=fromScorelist-%i-%@>Scorecard</a>. <br><a href=http://itunes.com/apps/golfmemoirgold>Buy your own GolfMemoir Application</a>."
#define  kGameURLString @"http://www.golfmemoir.com/index.php?panel=fromScorelist-%i-%@"
#define kGolfMemoirURL @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=284972636&mt=8"
#define kGolfMemoirGoldURL @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=310459827&mt=8"
#define kMeterToYardConversion 1.0936133


#define kGolfMemoirProductIdentifier @"GolfMemoir"
#define kGolfMemoirGoldProductIdentifier @"GolfMemoirGold"
#define kGolfMemoir_PhotoProductIdentifier @"GolfMemoir_Photo"
#define kGolfMemoir_Version 1
#define kGolfMemoirGold_Version 3


#define kHolesTab 0
#define kRoundsTab 1
#define kCoursesTab 2


#define kBlackTee 1
#define kBlueTee 2
#define kWhiteTee 0
#define kRedTee 3

#define kMaxHandicapIndex 36
#define kInvalidHI -100.0
//#define kMapSpanLatitudeDelta 0.004
#define kMapSpanLatitudeDelta 250.0/69000.0
#define kMapUserLocationOffset 150

#define kPrivacyPolicy @"Golf Memoir retrieves the friend information from your contacts. This application will store the contact information if you record scores for your friends. This application also uses your location information when you are playing a game. This location information is also used to replay your game information." 

#define kPrivacyPolicyAccept @" Please accept this policy, otherwise you will not be able to use this application."


//#define kAppVersion2Upgrade "ALTER TABLE  `coursehole` ADD  `holeType` INTEGER NULL, ADD  `teeLongitude` DOUBLE NULL , ADD  `teeLatitude` DOUBLE NULL , ADD  `frontLongitude` DOUBLE NULL , ADD  `frontLatitude` DOUBLE NULL , ADD  `backLongitude` DOUBLE NULL , ADD  `backLatitude` DOUBLE NULL"

//version 2 changes
#define kAppVersion2Upgrade1 "ALTER TABLE coursehole ADD 'holeType' INTEGER"
#define kAppVersion2Upgrade2 "ALTER TABLE coursehole ADD 'teeLongitude' DOUBLE"
#define kAppVersion2Upgrade3 "ALTER TABLE coursehole ADD 'teeLatitude' DOUBLE"
#define kAppVersion2Upgrade4 "ALTER TABLE coursehole ADD 'frontLongitude' DOUBLE"
#define kAppVersion2Upgrade5 "ALTER TABLE coursehole ADD 'frontLatitude' DOUBLE"
#define kAppVersion2Upgrade6 "ALTER TABLE coursehole ADD 'backLongitude' DOUBLE"
#define kAppVersion2Upgrade7 "ALTER TABLE coursehole ADD 'backLatitude' DOUBLE"


//version 4 changes
#define kAppVersion4Upgrade1 "ALTER TABLE score ADD 'teeType' INTEGER"
#define kAppVersion4Upgrade2 "ALTER TABLE hole ADD 'puttNum' INTEGER"
#define kAppVersion4Upgrade3 "ALTER TABLE hole ADD 'puttNum2' INTEGER"
#define kAppVersion4Upgrade4 "ALTER TABLE hole ADD 'puttNum3' INTEGER"
#define kAppVersion4Upgrade5 "ALTER TABLE hole ADD 'puttNum4' INTEGER"


//version 5 changes: added user table
#define kAppVersion5Upgrade1 "CREATE TABLE user ('pk' INTEGER, 'serverpk' INTEGER, 'username' CHAR(48), 'password' CHAR(48), 'udid' CHAR(48), 'service' INTEGER)"
#define kAppVersion5Upgrade2 "ALTER TABLE score ADD 'serverpk' INTEGER"
#define kAppVersion5Upgrade3 "ALTER TABLE course ADD 'courseAddress' CHAR(100)"
#define kAppVersion5Upgrade4 "ALTER TABLE course ADD 'courseCity' CHAR(25)"
#define kAppVersion5Upgrade5 "ALTER TABLE course ADD 'courseState' CHAR(25)"
#define kAppVersion5Upgrade6 "ALTER TABLE course ADD 'courseCountry' CHAR(25)"
#define kAppVersion5Upgrade7 "ALTER TABLE course ADD 'coursePhone' CHAR(50)"
#define kAppVersion5Upgrade8 "ALTER TABLE course ADD 'courseWebsite' CHAR(50)"
#define kAppVersion5Upgrade9 "ALTER TABLE course ADD 'courseZipcode' CHAR(25)"
#define kAppVersion5Upgrade10 "update app set appVersion=5 where pk=1"


//version 6 changes
#define kAppVersion6Upgrade1 "ALTER TABLE score ADD 'gameType' INTEGER"
#define kAppVersion6Upgrade2 "update app set appVersion=6 where pk=1"


//version 7 changes
#define kAppVersion7Upgrade1 "ALTER TABLE user ADD 'playerName' TEXT"
#define kAppVersion7Upgrade2 "ALTER TABLE user ADD 'contactID' INTEGER"
#define kAppVersion7Upgrade3 "ALTER TABLE user ADD 'fbUID' INTEGER"
#define kAppVersion7Upgrade12 "ALTER TABLE user ADD 'latestHI' REAL"
#define kAppVersion7Upgrade4 "ALTER TABLE score ADD 'hi' REAL"
#define kAppVersion7Upgrade5 "ALTER TABLE score ADD 'hi2' REAL"
#define kAppVersion7Upgrade6 "ALTER TABLE score ADD 'hi3' REAL"
#define kAppVersion7Upgrade7 "ALTER TABLE score ADD 'hi4' REAL"
#define kAppVersion7Upgrade8 "ALTER TABLE score ADD 'latestHI' REAL"
#define kAppVersion7Upgrade9 "ALTER TABLE score ADD 'fbUID2' INTEGER"
#define kAppVersion7Upgrade10 "ALTER TABLE score ADD 'fbUID3' INTEGER"
#define kAppVersion7Upgrade11 "ALTER TABLE score ADD 'fbUID4' INTEGER"
#define kAppVersion7Upgrade13 "update app set appVersion=7 where pk=1"

//version 8 is data update

//version 9 changes
#define kAppVersion9Upgrade1 "ALTER TABLE score ADD 'scoreType' INTEGER DEFAULT 0"
#define kAppVersion9Upgrade2 "update app set appVersion=9 where pk=1"

