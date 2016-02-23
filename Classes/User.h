//
//  AppSettings.h
//  GolfMemoir
//
//  Created by naresh gupta on 9/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <AddressBook/ABPerson.h>
#import "FBConnect/FBConnect.h"


@interface User : NSObject {
    // Opaque reference to the underlying database.
    sqlite3 *database;
    // Attributes.
    NSInteger pk;
    NSInteger serverpk;
    NSString *userName;
    NSString *password;
    NSString *udid;
    NSInteger service;
    NSString *playerName;
    ABRecordID	 contactID;
    FBUID	 fbUID;
	double latestHI;
}

@property (assign, nonatomic) NSInteger pk;
@property (assign, nonatomic) NSInteger serverpk;
@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSString *password;
@property (retain, nonatomic) NSString *udid;
@property (assign, nonatomic) NSInteger service;
@property (retain, nonatomic) NSString *playerName;
@property (assign, nonatomic) ABRecordID	 contactID;
@property (assign, nonatomic) FBUID	 fbUID;
@property (assign, nonatomic) double latestHI;

+ (void)finalizeStatements;
- (id)initWithDB:(sqlite3 *)db;
- (void)toDB;
- (void)fromDB;
-(void)insertNew;
-(void)updateService;
-(void)uploadService;


@end
