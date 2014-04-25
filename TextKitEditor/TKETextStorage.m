//
//  TKETextStorage.m
//  TextKitEditor
//
//  Created by Max Seelemann on 25.04.14.
//  Copyright (c) 2014 Max Seelemann. All rights reserved.
//

#import "TKETextStorage.h"

#import "TKECodeString.h"


@implementation TKETextStorage
{
	// Cache with precomupted attributes used for performance and convenience.
	NSMutableAttributedString *_cache;
}


- (id)init
{
    self = [super init];
    
    if (self) {
        _cache = [NSMutableAttributedString new];
    }
	
    return self;
}


#pragma mark - Accessors

- (void)setContent:(TKECodeString *)content
{
	_content = content;
	
	// Coalesce change notifications
	[self beginEditing];
	
	// Re-build string cache
	NSInteger oldLength = _cache.length;
	[_cache replaceCharactersInRange:NSMakeRange(0, oldLength) withString:_content];
	[self edited:NSTextStorageEditedCharacters range:NSMakeRange(0, oldLength) changeInLength:(NSInteger)_content.length - oldLength];
	
	// Compute attributes
	[self updateAttributesForChangedRange: NSMakeRange(0, _content.length)];
	
	// End coalescing change notifications
	[self endEditing];
}

- (void)setFont:(UIFont *)font
{
	_font = font;
	
	// Re-compute attributes
	[self beginEditing];
	[self updateAttributesForChangedRange: NSMakeRange(0, self.content.length)];
	[self endEditing];
}

- (NSUInteger)paragraphNumberForParagraphAtIndex:(NSUInteger)index
{
	// Simple forward here. But since only the text storage "knows" about the mapping from content to cache (1:1) we better loop it through here.
	return [_content paragraphNumberForParagraphAtIndex: index];
}


#pragma mark - Text Storage Accessors

- (NSString *)string
{
	return _cache.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
	return [_cache attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
	NSAssert(self.content != nil, @"Content has not been set!");
	
	// Update content and cache -- attributes will be re-computed later
	[self.content replaceCharactersInRange:range withString:str];
	[_cache replaceCharactersInRange:range withString:str];
	
	// Notify textual change
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
	// Update cache with new attributes only.
	[_cache setAttributes:attrs range:range];
	
	// Notify attribute change
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}


#pragma mark - Attribute computation

- (void)processEditing
{
	// Text has been changed in content and cache, now update the text colors as well
	[self updateAttributesForChangedRange: self.editedRange];
	
	// Call super *after* changing the attributes, as it finalizes the attributes and calls the delegate methods.
	[super processEditing];
}

- (UIColor *)textColorForCodeType:(TKECodeType)type
{
	switch (type) {
		default:
		case TKECodeTypeText:
			return UIColor.blackColor;
			
		case TKECodeTypeComment:
			return [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
			
		case TKECodeTypePragma:
			return [UIColor colorWithRed:0.4 green:0.2 blue:0 alpha:1];
			
		case TKECodeTypeKeyword:
			return [UIColor colorWithRed:0.7 green:0 blue:0.3 alpha:1];
	}
}

- (void)updateAttributesForChangedRange:(NSRange)range
{
	// Always re-compute complete paragraphs, the string requires us to
	range = [self.content paragraphRangeForRange: range];
	
	// Clear all current attributes
	[self setAttributes:@{} range:range];
	
	// Set font attribute
	if (self.font)
		[self addAttribute:NSFontAttributeName value:self.font range:range];
	
	// Enumerate code types in range
	[self.content enumerateCodeInRange:range usingBlock:^(NSRange range, TKECodeType type) {
		// Text color depends on type
		[self addAttribute:NSForegroundColorAttributeName value:[self textColorForCodeType: type] range:range];
	}];
}

@end
