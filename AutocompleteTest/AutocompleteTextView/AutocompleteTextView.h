//
//  AutocompleteTextView.h
//  AutocompleteTest
//
//  Created by Peter Dolganov on 22/08/2017.
//  Copyright © 2017 Peter Dolganov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AutocompleteTextView;

@protocol AutocompleteTextViewDelegate <NSObject>

@optional

- (void)autocompleteTextView:(AutocompleteTextView *)textView
      didChangeNumberOfLines:(NSUInteger)prevNumberOfLines;

@end

@protocol AutocompleteTextViewDataSource <NSObject>

- (void)autocompleteTextView:(AutocompleteTextView *)textView
                   forPrefix:(NSString *)prefix
              withCompletion:(void(^)(NSArray *suggestions))completionBlock;

@end

@interface AutocompleteTextView : UITextView

@property (nonatomic, weak) id<AutocompleteTextViewDelegate> autocompleteDelegate;
@property (nonatomic, weak) id<AutocompleteTextViewDataSource> autocompleteDataSource;

// Text View Properties

/*
 * Returns correct email contacts that contains in the text view
 */
@property (nonatomic, strong, readonly) NSSet *emailContacts;
/*
 * Text view extended maximum line number, default is 4
 */
@property (nonatomic, assign) NSUInteger textViewMaxLineNumber;
/*
 * Current number of lines in text view
 */
@property (nonatomic, assign, readonly) NSUInteger textViewNumberOfLines;
/*
 * Color for highlighted emails, default is [UIColor blueColor]
 */
@property (nonatomic, strong) UIColor *textViewHighlightedTextColor;
/*
 * Color for non-email strings, default is [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *textViewTextColor;


// Autocomplete Table Properties

/*
 * Autocomplete table view background color, default is [UIColor clearColor]
 */
@property (nonatomic, strong) UIColor *tableBackgroundColor;
/*
 * Autocomplete table view cell background color, default is [UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *tableCellBackgroundColor;
/*
 * Autocomplete table view text color, default is [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *tableTextColor;
/*
 * Autocomplete table view font size, default is 16
 */
@property (nonatomic, assign) CGFloat tableFontSize;
/*
 * Autocomplete table view border color, default is [UIColor lightGrayColor]
 */
@property (nonatomic, strong) UIColor *tableBorderColor;
/*
 * Autocomplete table view border width, default is 0.5
 */
@property (nonatomic, assign) CGFloat tableBorderWidth;
/*
 * Autocomplete table view maximum rows number, default is 4
 */
@property (nonatomic, assign) NSUInteger tableMaxRowsNumber;
/*
 * Autocomplete table view row height, default is 40
 */
@property (nonatomic, assign) CGFloat tableRowHeight;

@end
