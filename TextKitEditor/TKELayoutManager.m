//
//  TKELayoutManager.m
//  TextKitEditor
//
//  Created by Max Seelemann on 25.04.14.
//  Copyright (c) 2014 Max Seelemann. All rights reserved.
//

#import "TKELayoutManager.h"

#import "TKETextStorage.h"


#define TKELayoutManagerParagraphNumberInset	16.


@interface TKELayoutManager () <NSLayoutManagerDelegate>
@end

@implementation TKELayoutManager

- (id)init
{
    self = [super init];
    
    if (self) {
		// Let the layout manager handle the delegate by itself. Makes code more contained.
        self.delegate = self;
		
		// Set up some state
		_showParagraphNumbers = NO;
		_tabWidth = 2;
		_lineHeight = 1;
    }
	
    return self;
}


#pragma mark - Layout Properties

- (void)setShowParagraphNumbers:(BOOL)showParagraphNumbers
{
	_showParagraphNumbers = showParagraphNumbers;
	[self invalidateLayoutForCharacterRange:NSMakeRange(0, self.textStorage.length) actualCharacterRange:NULL];
}

- (void)setTabWidth:(NSUInteger)tabWidth
{
	_tabWidth = tabWidth;
	[self invalidateLayoutForCharacterRange:NSMakeRange(0, self.textStorage.length) actualCharacterRange:NULL];
}

- (void)setLineHeight:(CGFloat)lineHeight
{
	_lineHeight = lineHeight;
	[self invalidateLayoutForCharacterRange:NSMakeRange(0, self.textStorage.length) actualCharacterRange:NULL];
}


#pragma mark - Layout Computation

- (UIEdgeInsets)insetsForLineStartingAtCharacterIndex:(NSUInteger)characterIndex
{
	CGFloat leftInset = 0;
	
	// Base inset when showing paragraph numbers
	if (self.showParagraphNumbers)
		leftInset += TKELayoutManagerParagraphNumberInset;
	
	// For wrapped lines, determine where line is supposed to start
	NSRange paragraphRange = [self.textStorage.string paragraphRangeForRange: NSMakeRange(characterIndex, 0)];
	if (paragraphRange.location < characterIndex) {
		// Get the first glyph index in the paragraph
		NSUInteger firstGlyphIndex = [self glyphIndexForCharacterAtIndex: paragraphRange.location];

		// Get the first line of the paragraph
		NSRange firstLineGlyphRange;
		[self lineFragmentRectForGlyphAtIndex:firstGlyphIndex effectiveRange:&firstLineGlyphRange];
		NSRange firstLineCharRange = [self characterRangeForGlyphRange:firstLineGlyphRange actualGlyphRange:NULL];
		
		// Find the first wrapping char (here we use brackets), and wrap one char behind
		NSUInteger wrappingCharIndex = NSNotFound;
		wrappingCharIndex = [self.textStorage.string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString: @"({["] options:0 range:firstLineCharRange].location;
		if (wrappingCharIndex != NSNotFound)
			wrappingCharIndex += 1;
		
		// Alternatively, fall back to the first text (ie. non-whitespace) char
		if (wrappingCharIndex == NSNotFound) {
			wrappingCharIndex = [self.textStorage.string rangeOfCharacterFromSet:[NSCharacterSet.whitespaceCharacterSet invertedSet] options:0 range:firstLineCharRange].location;
			if (wrappingCharIndex != NSNotFound)
				wrappingCharIndex += 4;
		}
		
		// Wrapping char found, determine indent
		if (wrappingCharIndex != NSNotFound) {
			NSUInteger firstTextGlyphIndex = [self glyphIndexForCharacterAtIndex: wrappingCharIndex];
			
			// The additional indent is the distance from the first to the last character
			leftInset += [self locationForGlyphAtIndex: firstTextGlyphIndex].x - [self locationForGlyphAtIndex: firstGlyphIndex].x;
		}
	}
	
	// For now we compute left insets only, but rigth inset is also possible
	return UIEdgeInsetsMake(0, leftInset, 0, 0);
}


#pragma mark - Layout Handling

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
	// Line height is a multiple of the complete line, here we need only the extra space
	return (MAX(_lineHeight, 1) - 1) * rect.size.height;
}

- (void)setLineFragmentRect:(CGRect)fragmentRect forGlyphRange:(NSRange)glyphRange usedRect:(CGRect)usedRect
{
	// IMPORTANT: Perform the shift of the X-coordinate that cannot be done in NSTextContainer's -lineFragmentRectForProposedRect:atIndex:writingDirection:remainingRect:
	UIEdgeInsets insets = [self insetsForLineStartingAtCharacterIndex: [self characterIndexForGlyphAtIndex: glyphRange.location]];
	
	fragmentRect.origin.x += insets.left;
	usedRect.origin.x += insets.left;
	
	[super setLineFragmentRect:fragmentRect forGlyphRange:glyphRange usedRect:usedRect];
}

- (NSControlCharacterAction)layoutManager:(NSLayoutManager *)layoutManager shouldUseAction:(NSControlCharacterAction)action forControlCharacterAtIndex:(NSUInteger)charIndex
{
	// We want to adjust the positions for tab characters
	if ([self.textStorage.string characterAtIndex: charIndex] == '\t')
		return NSControlCharacterWhitespaceAction;
	
	// Default action
	return action;
}

- (CGRect)layoutManager:(NSLayoutManager *)layoutManager boundingBoxForControlGlyphAtIndex:(NSUInteger)glyphIndex forTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)proposedRect glyphPosition:(CGPoint)glyphPosition characterIndex:(NSUInteger)charIndex
{
	// Determine tab width. WARNING: The tab width computation is crazily expensive. Must be cached.
	UIFont *primaryFont = ((TKETextStorage *)self.textStorage).font;
	CGFloat nWidth = [@"n" boundingRectWithSize:CGSizeMake(1000, 1000) options:0 attributes:@{NSFontAttributeName: primaryFont} context:nil].size.width;
	
	// Determine END of tab character
	CGFloat tabSize = nWidth * self.tabWidth;
	CGFloat tabPosition = floor((glyphPosition.x + nWidth/2) / tabSize + 1) * tabSize;

	// Bounding rect from position to computed tab position
	CGRect rect = CGRectZero;
	rect.origin = glyphPosition;
	rect.size.width = tabPosition - glyphPosition.x;
	
	return rect;
}


#pragma mark - Drawing

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
	[super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
	
	// Draw paragraph numbers if enabled
	if (self.showParagraphNumbers)
		[self drawParagraphNumbersForGlyphRange:glyphsToShow atPoint:origin];
}

- (void)drawParagraphNumbersForGlyphRange:(NSRange)glyphRange atPoint:(CGPoint)origin
{
	// Enumerate all lines
	NSUInteger glyphIndex = glyphRange.location;
	
	while (glyphIndex < NSMaxRange(glyphRange)) {
		NSRange glyphLineRange;
		CGRect lineFragmentRect = [self lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&glyphLineRange];
		
		// Check for paragraph start
		NSRange lineRange = [self characterRangeForGlyphRange:glyphLineRange actualGlyphRange:NULL];
		NSRange paragraphRange = [self.textStorage.string paragraphRangeForRange: lineRange];
		
		// Draw paragraph number if we're at the start of a paragraph
		if (lineRange.location == paragraphRange.location)
			[self drawParagraphNumberForCharRange:paragraphRange lineFragmentRect:lineFragmentRect atPoint:origin];
		
		// Advance
		glyphIndex = NSMaxRange(glyphLineRange);
	}
}

- (void)drawParagraphNumberForCharRange:(NSRange)charRange lineFragmentRect:(CGRect)lineRect atPoint:(CGPoint)origin
{
	// Get number of paragraph
	NSUInteger paragraphNumber = [(TKETextStorage *)self.textStorage paragraphNumberForParagraphAtIndex: charRange.location];
	
	// Prepare rendering attributes -- get string, attribute and size
	NSString *numberString = [NSString stringWithFormat: @"%lu", (unsigned long)paragraphNumber];
	NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor colorWithWhite:0.3 alpha:1],
								  NSFontAttributeName: [UIFont systemFontOfSize: 9] };
	
	CGFloat height = [numberString boundingRectWithSize:CGSizeMake(1000, 1000) options:0 attributes:attributes context:nil].size.height;
	
	// Rect for number to be drawn into
	CGRect numberRect;
	numberRect.size.width = lineRect.origin.x;
	numberRect.origin.x = origin.x;
	numberRect.size.height = height;
	numberRect.origin.y = CGRectGetMidY(lineRect) - height*0.5 + origin.y;
	
	// Actual drawing of paragroh number
	[numberString drawWithRect:numberRect options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
}

@end
