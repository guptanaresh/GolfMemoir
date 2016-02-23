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


@interface AppSettings : NSObject {
    // Opaque reference to the underlying database.
    sqlite3 *database;
    // Attributes.
    NSInteger pk;
    NSInteger appVersion;
    NSInteger privacyAccepted;
	
}

@property (assign, nonatomic) NSInteger pk;
@property (assign, nonatomic) NSInteger appVersion;
@property (assign, nonatomic) NSInteger privacyAccepted;

+ (void)finalizeStatements;
- (id)initWithDB:(sqlite3 *)db;
- (void)toDB;
- (void)fromDB;
-(void)insertNew;
@end
