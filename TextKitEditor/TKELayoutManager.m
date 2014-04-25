//
//  TKELayoutManager.m
//  TextKitEditor
//
//  Created by Max Seelemann on 25.04.14.
//  Copyright (c) 2014 Max Seelemann. All rights reserved.
//

#import "TKELayoutManager.h"

#import "TKETextStorage.h"


@interface TKELayoutManager () <NSLayoutManagerDelegate>
@end

@implementation TKELayoutManager

- (id)init
{
    self = [super init];
    
    if (self) {
		// Let the layout manager handle the delegate by itself. Makes code more contained.
        self.delegate = self;
    }
	
    return self;
}


#pragma mark - Layout Computation

- (UIEdgeInsets)insetsForLineStartingAtCharacterIndex:(NSUInteger)characterIndex
{
	return UIEdgeInsetsMake(0, 20, 0, 0);
}


#pragma mark - Layout Handling

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
	// Just a little bit more line spacing everywhere -- 10%
	return 0.1 * rect.size.height;
}

- (void)setLineFragmentRect:(CGRect)fragmentRect forGlyphRange:(NSRange)glyphRange usedRect:(CGRect)usedRect
{
	// IMPORTANT: Perform the shift of the X-coordinate that cannot be done in NSTextContainer's -lineFragmentRectForProposedRect:atIndex:writingDirection:remainingRect:
	UIEdgeInsets insets = [self insetsForLineStartingAtCharacterIndex: [self characterIndexForGlyphAtIndex: glyphRange.location]];
	
	fragmentRect.origin.x += insets.left;
	usedRect.origin.x += insets.left;
	
	[super setLineFragmentRect:fragmentRect forGlyphRange:glyphRange usedRect:usedRect];
}


#pragma mark - Drawing

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
	[super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
	
	// Enumerate all lines
	NSUInteger glyphIndex = glyphsToShow.location;
	
	while (glyphIndex < NSMaxRange(glyphsToShow)) {
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
