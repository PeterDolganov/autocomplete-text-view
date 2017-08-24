//
//  NSString+Email.h
//  AutocompleteTest
//
//  Created by Peter Dolganov on 22/08/2017.
//  Copyright © 2017 Peter Dolganov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Email)

- (BOOL)isValidEmail;

- (NSString *)removeCommas;
- (NSString *)removeWhiteSpaces;

@end
