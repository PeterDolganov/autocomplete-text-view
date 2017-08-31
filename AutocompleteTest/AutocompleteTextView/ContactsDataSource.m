//
//  ContactsDataSource.m
//  AutocompleteTest
//
//  Created by Peter Dolganov on 21/08/2017.
//  Copyright © 2017 Peter Dolganov. All rights reserved.
//

#import "ContactsDataSource.h"

@interface ContactsDataSource ()

@property (nonatomic, strong) NSMutableArray<NSString *> *contacts;

@end

@implementation ContactsDataSource

#pragma mark - Private methods

- (id)initPrivate
{
    self = [super init];
    
    if (self)
    {
        // stubs contacts
        _contacts = [[NSMutableArray alloc] initWithObjects:
                     @"alexander.muhin@ya.ru",
                     @"alexey.petuhov@mail.ru",
                     @"andrey.kruglov@gmail.com",
                     @"anatoly.ivanov@mail.ru",
                     @"anton_shipulin@rampler.ru",
                     @"artem.noskov@gmail.com",
                     @"artem.velikanov@yahoo.com",
                     @"boris_borisov@mail.ru",
                     @"dmitry.sidorov@gmail.com",
                     @"denis.petrov@gmail.com",
                     @"ilya.ustinov@rambler.ru",
                     @"igor.novikov@yandex.ru",
                     @"nikolay_kruglov@mail.ru",
                     @"pavel123@ya.ru",
                     @"peter.dolganov@gmail.com",
                     @"sergey@rambler.ru",
                     @"vasya.pupkin@gmail.com",
                     @"vasiliy.ribakov@gmail.com",
                     @"victor.sitnev@yandex.ru",
                     @"vladimir.romanov@mail.ru",
                     nil];

        // load contacts from address book or extract saved in app contacts here; sotr it if necessary
    }
    return self;
}

#pragma mark - Public methods

+ (ContactsDataSource *)sharedInstance
{
    static ContactsDataSource* sharedMgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMgr = [[ContactsDataSource alloc] initPrivate];
    });
    return sharedMgr;
}

- (NSArray *)suggestionsForPrefix:(NSString *)prefix
{
    NSMutableArray *suggestions = [NSMutableArray array];

    if (prefix.length == 0)
    {
        return suggestions; // return empty array for empty prefix
    }
    
    prefix = [prefix lowercaseString];

    for (NSString *contact in self.contacts)
    {
        if ([contact hasPrefix:prefix])
        {
            [suggestions addObject:contact];
        }
    }
    return suggestions;
}

#pragma mark - AutocompleteTextViewDataSource methods

- (void)autocompleteTextView:(AutocompleteTextView *)textView forPrefix:(NSString *)prefix withCompletion:(void(^)(NSArray *suggestions))completionBlock
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSArray *suggestions = [self suggestionsForPrefix:prefix];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            completionBlock(suggestions);
        });
    });
}

@end
