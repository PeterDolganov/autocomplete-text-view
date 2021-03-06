//
//  NSString+Utils.h
//  AutocompleteTest
//
//  Created by Peter Dolganov on 22/08/2017.
//  Copyright © 2017 Peter Dolganov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

- (BOOL)isValidEmail;

- (NSString *)removeCommas;
- (NSString *)removeWhiteSpaces;
- (NSString *)removeNewLines;
- (NSString *)removeDuplicateWords;

- (NSArray *)wordsFromString;

- (NSRange)wordRangeForRangePosition:(NSUInteger)position;
- (BOOL)rangeExists:(NSRange)range;

@end
