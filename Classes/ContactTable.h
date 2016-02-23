//
//  ContactTable.h
//  GolfMemoir
//
//  Created by naresh gupta on 6/7/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface ContactTable : NSObject <UITableViewDataSource, UITableViewDelegate> {
		ABAddressBookRef addressBook;
		NSArray *allPeople;
	NSMutableArray *selected;
}

@property (nonatomic,assign) ABAddressBookRef addressBook;
@property (nonatomic,assign) NSArray *allPeople;
@property (nonatomic,assign) NSMutableArray *selected;

-(void) initFields;
- (NSString *)stringValueForRow:(NSInteger)row;
- (NSArray *)getAllPeople;	

@end
