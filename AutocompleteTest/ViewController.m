//
//  ViewController.m
//  AutocompleteTest
//
//  Created by Peter Dolganov on 22/08/2017.
//  Copyright © 2017 Peter Dolganov. All rights reserved.
//

#import "ViewController.h"
#import "AutocompleteTextView.h"

@interface ViewController () <AutocompleteTextViewDelegate>

@property (nonatomic, strong) IBOutlet AutocompleteTextView *textView1;
@property (nonatomic, strong) IBOutlet AutocompleteTextView *textView2;

// constraints
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* textView1HeightConstr;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* textView2HeightConstr;

@end

@implementation ViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.textView1.autocompleteDelegate = self;
    self.textView2.autocompleteDelegate = self;

    // developer can set text view properties and autocomplete table view properties here
}

#pragma mark - AutocompleteTextViewDelegate methods

- (void)autocompleteTextView:(AutocompleteTextView *)textView didChangeNumberOfLines:(NSUInteger)prevNumberOfLines
{
    // Some UI updates (control alignments) may be implemented here.
    // The current number of lines can be get from textView.textViewNumberOfLines
    
    if (textView == self.textView1)
    {
        self.textView1HeightConstr.constant = textView.frame.size.height;
    }
    else if (textView == self.textView2)
    {
        self.textView2HeightConstr.constant = textView.frame.size.height;
    }
}

@end
