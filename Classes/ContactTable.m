//
//  ContactTable.m
//  GolfMemoir
//
//  Created by naresh gupta on 6/7/08.
//  Copyright 2008 JAJSoftware. All rights reserved.
//

#import "ContactTable.h"


@implementation ContactTable

@synthesize addressBook, allPeople, selected;


-(id)init
{
	self = [super init];
	[self initFields];
	return self;
}

-(void) initFields{
	// open the default address book.
    CFErrorRef* error;
	ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(addressbook, nil);
    if (!addressbook) {
        NSLog(@"opening address book");
    }
	
	// can be cast to NSArray, toll-free
	allPeople = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressbook);
	selected = [[NSMutableArray alloc] init];
}

- (ABAddressBookRef)getAddressBook {
	if (nil == addressBook)
	{
        CFErrorRef* error;
        addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABAddressBookRequestAccessWithCompletion(addressBook, nil);
	}
	return addressBook;
}
- (NSArray *)getAllPeople {
	if (nil == allPeople)
	{
		allPeople = (NSArray *)ABAddressBookCopyArrayOfAllPeople(self.addressBook);
	}
	return allPeople;
}

- (NSString *)stringValueForRow:(NSInteger)row
{
	ABRecordRef aPerson = [[self getAllPeople] objectAtIndex:row];
	NSString *contactFirstLast = (NSString *)ABRecordCopyCompositeName(aPerson);
	return contactFirstLast;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [allPeople count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *MyIdentifier = [@"MyIdentifier" stringByAppendingFormat:@"%i", indexPath.row];
	
	// Try to retrieve from the table view a now-unused cell with the given identifier
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	// If no cell is available, create a new one using the given identifier
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
	}
	// Set up the cell
	cell.textLabel.text = [self stringValueForRow:indexPath.row];
	return cell;
}


- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
    [theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:newIndexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
		if(selected.count < 3){
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			[selected addObject:newIndexPath];
		}
        // Set model-object attribute associated with row
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        // Unset model-object attribute associated with row
		[selected removeObject:newIndexPath];
    }
}


- (void)dealloc {
	[super dealloc];
}


@end
