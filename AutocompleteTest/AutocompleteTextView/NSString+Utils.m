//
//  NSString+Utils.m
//  AutocompleteTest
//
//  Created by Peter Dolganov on 22/08/2017.
//  Copyright © 2017 Peter Dolganov. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (BOOL)isValidEmail
{
    NSString *emailRegex = @"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:self];
    return isValid;
}

- (NSString *)removeCommas
{
    NSString *result;
    
    NSCharacterSet *commas = [NSCharacterSet characterSetWithCharactersInString:@","];
    result = [[self componentsSeparatedByCharactersInSet:commas] componentsJoinedByString:@""];

    return result;
}

- (NSString *)removeWhiteSpaces
{
    NSString *result;
    
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [self componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    result = [filteredArray componentsJoinedByString:@" "];
    
    return result;
}

- (NSString *)removeNewLines
{
    NSString *result;
    
    NSCharacterSet *newlines = [NSCharacterSet newlineCharacterSet];
    result = [[self componentsSeparatedByCharactersInSet:newlines] componentsJoinedByString:@""];
    
    return result;
}

- (NSString *)removeDuplicateWords
{
    NSArray *words = [[NSOrderedSet orderedSetWithArray:[self wordsFromString]] array];
    NSString *result = [words componentsJoinedByString: @" "];
    return result;
}

- (NSArray *)wordsFromString
{
    NSString *resultString = [self removeCommas];
    NSArray *words = [resultString componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

    return words;
}

- (NSRange)wordRangeForRangePosition:(NSUInteger)position
{
    NSCharacterSet *wordCharacterSet = [[NSCharacterSet whitespaceCharacterSet] invertedSet];
    NSInteger adjustedIndex = position;

    while (adjustedIndex < self.length && ![wordCharacterSet characterIsMember:[self characterAtIndex:adjustedIndex]])
    {
        ++adjustedIndex;
    }
    if (adjustedIndex == self.length)
    {
        do
        {
            --adjustedIndex;
        }
        while (adjustedIndex >= 0 && ![wordCharacterSet characterIsMember:[self characterAtIndex:adjustedIndex]]);
        if (adjustedIndex == -1)
        {
            return NSMakeRange(0, 0);
        }
    }
    
    NSInteger beforeBeginning = adjustedIndex;
    while (beforeBeginning >= 0 && [wordCharacterSet characterIsMember:[self characterAtIndex:beforeBeginning]])
    {
        --beforeBeginning;
    }
    
    NSInteger afterEnd = adjustedIndex;
    while (afterEnd < self.length && [wordCharacterSet characterIsMember:[self characterAtIndex:afterEnd]])
    {
        ++afterEnd;
    }

    NSRange range = NSMakeRange(beforeBeginning + 1, afterEnd - beforeBeginning - 1);
    return range;
}

@end
