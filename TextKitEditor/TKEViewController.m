//
//  TKEViewController.m
//  TextKitEditor
//
//  Created by Max Seelemann on 25.04.14.
//  Copyright (c) 2014 Max Seelemann. All rights reserved.
//

#import "TKEViewController.h"

#import "TKECodeString.h"
#import "TKELayoutManager.h"
#import "TKETextContainer.h"
#import "TKETextStorage.h"


@interface TKEViewController ()
{
	// The code contents to be displayed in the view
	TKECodeString *_codeString;
	
	// Text storage must be held strongly, only the default storage is retained by the text view.
	TKETextStorage *_textStorage;
}
@end

@implementation TKEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_codeString = [TKECodeString new];
	_codeString.string = [NSString stringWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"demo" withExtension:@"txt"] usedEncoding:NULL error:NULL];
	
	// Create text system
	_textStorage = [TKETextStorage new];
	_textStorage.content = _codeString;
	_textStorage.font = [UIFont fontWithName:@"Menlo" size:13];
	
	TKELayoutManager *layoutManager = [TKELayoutManager new];
	layoutManager.lineHeight = 1.1;
	layoutManager.showParagraphNumbers = YES;
	layoutManager.tabWidth = 4;
	[_textStorage addLayoutManager: layoutManager];
	
	NSTextContainer *textContainer = [[TKETextContainer alloc] initWithSize: CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
	[layoutManager addTextContainer: textContainer];
	
	UITextView *textView = [[UITextView alloc] initWithFrame:CGRectInset(self.view.bounds, 10, 20) textContainer: textContainer];
	textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	textView.translatesAutoresizingMaskIntoConstraints = YES;
	textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
	textView.spellCheckingType = UITextSpellCheckingTypeNo;
	[self.view addSubview: textView];
}

@end
