//
//  ContactsDataSource.h
//  AutocompleteTest
//
//  Created by Peter Dolganov on 21/08/2017.
//  Copyright © 2017 Peter Dolganov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutocompleteTextView.h"

@interface ContactsDataSource : NSObject <AutocompleteTextViewDataSource>

+ (ContactsDataSource *)sharedInstance;

- (NSArray*)contacts;

- (void)addContact:(NSString *)email;

@end
