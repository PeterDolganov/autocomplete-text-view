//
//  NSString+Email.m
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
    
    NSArray *parts = [result componentsSeparatedByCharactersInSet:whitespaces];
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

- (NSArray *)wordsFromString
{
    NSString *resultString = [self removeCommas];
    NSArray *words = [resultString componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

    return words;
}

@end
