//
//  AutocompleteTextView.m
//  AutocompleteTest
//
//  Created by Peter Dolganov on 22/08/2017.
//  Copyright © 2017 Peter Dolganov. All rights reserved.
//

#import "AutocompleteTextView.h"
#import "ContactsDataSource.h"
#import "NSString+Utils.h"

@interface AutocompleteTextView () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *mTableView;
    NSArray *mSuggestions;
}

@property (assign) CGColorRef defaultShadowColor;
@property (assign) CGSize defaultShadowOffset;
@property (assign) CGFloat defaultShadowOpacity;
@property (assign) CGRect currentRect;
@property (assign) CGFloat defaultHeight;

@property (strong) NSDictionary *defaultAttributes;
@property (strong) NSDictionary *highlightedAttributes;

@end

@implementation AutocompleteTextView

#pragma mark - Lifecycle methods

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setupAutocompleteTextView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupAutocompleteTextView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect newFrame = [self calculateTableViewFrameForRows:[mSuggestions count]];
    [mTableView setFrame:newFrame];
    [mTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)setupAutocompleteTextView
{
    // setup data source provide
    ContactsDataSource *contactsDataSource = [ContactsDataSource sharedInstance];
    self.autocompleteDataSource = contactsDataSource;
    
    // set text view defaults
    [self setClipsToBounds:YES];
    [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self setKeyboardType:UIKeyboardTypeEmailAddress];
    [self setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self setShowsVerticalScrollIndicator:YES];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setReturnKeyType:UIReturnKeyDone];
    [self setSelectable:YES];
    [self setEditable:YES];
    [self setTextAlignment:NSTextAlignmentLeft];
    [self setFont:[UIFont systemFontOfSize:16]];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.5f;
    self.textViewMaxLineNumber = 4;
    _textViewNumberOfLines = 0;
    [self setDefaultHeight:self.frame.size.height];
    [self setTextViewTextColor:[UIColor blackColor]];
    [self setTextViewHighlightedTextColor:[UIColor blueColor]];

    self.defaultAttributes = @{NSForegroundColorAttributeName : self.textViewTextColor,
                               NSFontAttributeName: self.font};
    self.highlightedAttributes = @{NSForegroundColorAttributeName : self.textViewHighlightedTextColor,
                                   NSFontAttributeName: self.font};
    self.defaultHeight = [self.font lineHeight];

    // set table view defaults
    [self setTableCellBackgroundColor:[UIColor clearColor]];
    [self setTableBackgroundColor:[UIColor whiteColor]];
    [self setTableBorderColor:[UIColor clearColor]];
    [self setTableBorderWidth:0];
    [self setTableRowHeight:40];
    [self setTableFontSize:16];
    [self setTableMaxRowsNumber:4];
    
    // initialization
    CGRect frame = [self calculateTableViewFrameForRows:0];
    mTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    
    mSuggestions = [NSArray array];
    self.currentRect = CGRectZero;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];
}

#pragma mark - Getter and Setter methods

- (void)setTextViewTextColor:(UIColor *)textViewTextColor
{
    _textViewTextColor = textViewTextColor;
    self.defaultAttributes = @{NSForegroundColorAttributeName : self.textViewTextColor,
                               NSFontAttributeName: self.font};
}

- (void)setTextViewHighlightedTextColor:(UIColor *)textViewHighlightedTextColor
{
    _textViewHighlightedTextColor = textViewHighlightedTextColor;
    self.highlightedAttributes = @{NSForegroundColorAttributeName : self.textViewHighlightedTextColor,
                                   NSFontAttributeName: self.font};
}

- (void)setFont:(UIFont *)font
{
    super.font = font;
    self.defaultHeight = [font lineHeight];
}

- (NSSet *)emailContacts
{
    NSMutableSet *resultContacts = [NSMutableSet set];
    NSArray *words = [self.text wordsFromString];

    for (NSString *word in words)
    {
        if ([word isValidEmail])
        {
            [resultContacts addObject:word];
        }
    }
    return resultContacts;
}

#pragma mark - Handle UIResponder events

- (BOOL)becomeFirstResponder
{
    [self saveCurrentShadowProperties];
    [self refreshAutocompleteSuggestions];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [self hideSuggestionsTableView];
    return [super resignFirstResponder];
}

- (void)textViewTextDidChange:(NSNotification *)notification
{
    // handle return key event
    if ([self.text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound)
    {
        self.text = [self.text removeNewLines];
        [self resignFirstResponder];
        [self preventScrollText];
        return;
    }
    
    // re-calculate frames if needed
    NSUInteger prevNumberOfLines = self.textViewNumberOfLines;
    _textViewNumberOfLines = [self currentNumberOfLines];
    NSRange cursorPosition = [self selectedRange];
    
    if (prevNumberOfLines != self.textViewNumberOfLines && prevNumberOfLines > 0 && self.textViewNumberOfLines <= self.textViewMaxLineNumber)
    {
        // change text view size
        CGRect newFrame = self.frame;
        
        if (prevNumberOfLines < self.textViewNumberOfLines)
        {
            newFrame.size.height += self.defaultHeight;
        }
        else if (prevNumberOfLines <= self.textViewMaxLineNumber)
        {
            newFrame.size.height -= self.defaultHeight;
        }
        [self setFrame:newFrame];
        [self preventScrollText];
        
        if (self.autocompleteDelegate && [self.autocompleteDelegate respondsToSelector:@selector(autocompleteTextView: didChangeNumberOfLines:)])
        {
            [self.autocompleteDelegate autocompleteTextView:self didChangeNumberOfLines:prevNumberOfLines];
        }
    }

    // update string in text view
    [self updateAttributedTextForString:self.text];
    [self setSelectedRange:cursorPosition];
    
    // update suggestions if it possible
    [self refreshAutocompleteSuggestions];
    
    NSLog(@"currentNumberOfLines: %lu", (unsigned long)self.textViewNumberOfLines);
}

- (void)textViewTextDidEndEditing:(NSNotification *)notification
{
    if (self.autocompleteDelegate != nil && [self.autocompleteDelegate respondsToSelector:@selector(autocompleteTextView:didEndEditingWithEmails:)])
    {
        [self.autocompleteDelegate autocompleteTextView:self didEndEditingWithEmails:[self emailContacts]];
    }
}

- (void)refreshAutocompleteSuggestions
{
    if (self.autocompleteDataSource != nil && [self.autocompleteDataSource respondsToSelector:@selector(autocompleteTextView:forPrefix:withCompletion:)])
    {
        UITextRange *textRange = [self textRangeForCurrentlyEditedWord];
        NSString *currentWord = [self textInRange:textRange];
        
        [self.autocompleteDataSource autocompleteTextView:self forPrefix:currentWord withCompletion:^(NSArray *suggestions) {
            
            mSuggestions = suggestions;
            [mTableView reloadData];
            
            NSLog(@"Suggestions: %@", suggestions);
        }];
    }
}

#pragma mark - Text calculations

- (NSUInteger)currentNumberOfLines
{
    NSUInteger numberOfLines = self.textViewNumberOfLines;
    UITextPosition *pos = self.endOfDocument;
    CGRect newRect = [self caretRectForPosition:pos];
    
    if (newRect.origin.y > self.currentRect.origin.y)
    {
        // new line reached
        numberOfLines++;
    }
    else if (newRect.origin.y < self.currentRect.origin.y && numberOfLines > 1)
    {
        // last line removed
        numberOfLines--;
    }
    self.currentRect = newRect;
    return numberOfLines;
}

- (void)preventScrollText
{
    if (self.textViewNumberOfLines <= self.textViewMaxLineNumber)
    {
        // prevent scrolling text for this case
        [self scrollRangeToVisible:NSMakeRange(0, 0)];
    }
}

- (void)updateAttributedTextForString:(NSString *)resultString
{
    NSArray *words = [resultString wordsFromString];
    NSAttributedString *attrSpace = [[NSAttributedString alloc] initWithString:@", " attributes:self.defaultAttributes];
    NSMutableAttributedString *attrResultString = [[NSMutableAttributedString alloc] init];

    for (int i = 0; i < words.count; i++)
    {
        NSString *word = [words objectAtIndex:i];
        NSAttributedString *attrWord;

        if ([word isValidEmail])
        {
            attrWord = [[NSAttributedString alloc] initWithString:word attributes:self.highlightedAttributes];
        }
        else
        {
            attrWord = [[NSAttributedString alloc] initWithString:word attributes:self.defaultAttributes];
        }

        [attrResultString appendAttributedString:attrWord];

        if (!(i == words.count - 1 && ![word isValidEmail]) && ![word isEqualToString:@""])
        {
            [attrResultString appendAttributedString:attrSpace];
        }
    }
    
    self.text = resultString;
    self.attributedText = attrResultString;
}

- (NSAttributedString *)attributedString:(NSString *)string withRange:(NSRange)boldRange
{
    UIFont *boldFont = [UIFont boldSystemFontOfSize:self.tableFontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:self.tableFontSize];
    
    NSDictionary *boldTextAttributes = @{NSFontAttributeName : boldFont,
                                         NSForegroundColorAttributeName : [UIColor blackColor]};
    NSDictionary *regularTextAttributes = @{NSFontAttributeName : regularFont,
                                            NSForegroundColorAttributeName : [UIColor darkGrayColor]};
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:string attributes:regularTextAttributes];
    [attributedText setAttributes:boldTextAttributes range:boldRange];
    
    return attributedText;
}

- (UITextRange *)textRangeForCurrentlyEditedWord
{
    NSRange selectedRange = self.selectedRange;
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *start = [self positionFromPosition:beginning offset:selectedRange.location];
    UITextPosition *end = [self positionFromPosition:start offset:selectedRange.length];
    UITextRange *textRange = [self.tokenizer rangeEnclosingPosition:end withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionLeft];
    
    NSLog(@"Word that is currently being edited is : %@", [self textInRange:textRange]);
    
    return textRange;
}

#pragma mark - Frame Calculations

- (CGRect)calculateTableViewFrameForRows:(NSInteger)rowsNumber
{
    CGRect frame = self.frame;
    CGFloat height = [self calculateTableViewHeightForRows:rowsNumber];
    frame.origin.y += self.frame.size.height;
    frame.size.height = height;
    
    return frame;
}

- (CGFloat)calculateTableViewHeightForRows:(NSInteger)rowsNumber
{
    NSUInteger number;

    if (rowsNumber >= self.tableMaxRowsNumber)
    {
        number = self.tableMaxRowsNumber;
    }
    else
    {
        number = rowsNumber;
    }
    return self.tableRowHeight * number;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsNumber = [mSuggestions count];
    [self showSuggestionsTableViewForRows:rowsNumber];
    return rowsNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"defaultCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    // cell properties
    [cell.textLabel setTextColor:self.tableTextColor];
    [cell.textLabel setFont:[UIFont fontWithName:self.font.fontName size:self.tableFontSize]];
    [cell setBackgroundColor:self.tableCellBackgroundColor];

    // highlight selected characters
    NSString *contact = [mSuggestions objectAtIndex:indexPath.row];
    UITextRange *textRange = [self textRangeForCurrentlyEditedWord];
    NSString *currentWord = [self textInRange:textRange];
    NSRange boldedRange = [contact rangeOfString:currentWord options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];
    NSAttributedString *attrString = [self attributedString:contact withRange:boldedRange];
    
    if (attrString)
    {
        [cell.textLabel setAttributedText:attrString];
    }
    else
    {
        [cell.textLabel setText:contact];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *autoCompleteString = selectedCell.textLabel.text;

    UITextRange* leftTextRange = [self textRangeForCurrentlyEditedWord];
    [self replaceRange:leftTextRange withText:autoCompleteString];
    
    [self updateAttributedTextForString:self.text];
}

#pragma mark - Show/Hide suggestions table view

- (void)showSuggestionsTableViewForRows:(NSInteger)rowsNumber
{
    if (!self.isFirstResponder)
    {
        return;
    }

    CGRect newFrame = [self calculateTableViewFrameForRows:rowsNumber];
    
    [mTableView setFrame:newFrame];
    [mTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    if (rowsNumber > 0)
    {
        [self.superview bringSubviewToFront:self];
        [self.superview insertSubview:mTableView belowSubview:self];
        [mTableView setUserInteractionEnabled:YES];
        [self addShadowProperties];
    }
    else
    {
        [self hideSuggestionsTableView];
        [mTableView.layer setShadowOpacity:0.0];
    }
}

- (void)hideSuggestionsTableView
{
    [self resetDefaultShadowProperties];
    [mTableView removeFromSuperview];
}

- (void)saveCurrentShadowProperties
{
    [self setDefaultShadowColor:self.layer.shadowColor];
    [self setDefaultShadowOffset:self.layer.shadowOffset];
    [self setDefaultShadowOpacity:self.layer.shadowOpacity];
}

- (void)addShadowProperties
{
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.layer setShadowOpacity:0.25];
}

- (void)resetDefaultShadowProperties
{
    [self.layer setShadowColor:self.defaultShadowColor];
    [self.layer setShadowOffset:self.defaultShadowOffset];
    [self.layer setShadowOpacity:self.defaultShadowOpacity];
}

@end
