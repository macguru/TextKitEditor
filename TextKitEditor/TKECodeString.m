//
//  TKECodeString.m
//  TextKitEditor
//
//  Created by Max Seelemann on 25.04.14.
//  Copyright (c) 2014 Max Seelemann. All rights reserved.
//

#import "TKECodeString.h"

@implementation TKECodeString
{
	NSMutableString *_imp;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _imp = [NSMutableString new];
    }
	
    return self;
}


#pragma mark - String accessors

- (NSUInteger)length
{
	return _imp.length;
}

- (unichar)characterAtIndex:(NSUInteger)index
{
	return [_imp characterAtIndex: index];
}

- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange
{
	[_imp getCharacters:buffer range:aRange];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString
{
	[_imp replaceCharactersInRange:range withString:aString];
}


#pragma mark - Code enumeration

- (void)enumerateCodeInRange:(NSRange)range usingBlock:(void (^)(NSRange range, TKECodeType type))block
{
	NSParameterAssert(NSEqualRanges(range, [self paragraphRangeForRange: range]));
	
	// Enumerate lines
	[self enumerateSubstringsInRange:range options:NSStringEnumerationByParagraphs usingBlock:^(NSString *paragraph, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		// Detect comments
		if ([[paragraph stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet] hasPrefix: @"//"]) {
			block(enclosingRange, TKECodeTypeComment);
			return;
		}
		
		// Detect comments
		if ([paragraph hasPrefix: @"#"]) {
			block(enclosingRange, TKECodeTypePragma);
			return;
		}
		
		// Detect keywords
		[self enumerateSubstringsInRange:enclosingRange options:NSStringEnumerationByWords usingBlock:^(NSString *word, NSRange innerSubstringRange, NSRange innerEnclosingRange, BOOL *stop) {
			// Substring is a keyword
			if ([@[@"int", @"const", @"char", @"return"] containsObject: word]) {
				// Text before keyword is just text
				if (innerEnclosingRange.location < innerSubstringRange.location)
					block(NSMakeRange(innerEnclosingRange.location, innerSubstringRange.location - innerEnclosingRange.location), TKECodeTypeText);
				
				// Keyword is a keyword
				block(innerSubstringRange, TKECodeTypeKeyword);
				
				// Text behind keyword is just text
				if (NSMaxRange(innerEnclosingRange) > NSMaxRange(innerSubstringRange))
					block(NSMakeRange(NSMaxRange(innerSubstringRange), NSMaxRange(innerEnclosingRange) - NSMaxRange(innerSubstringRange)), TKECodeTypeText);
			}
			// No keyword match, it's just text
			else {
				block(innerEnclosingRange, TKECodeTypeText);
			}
		}];
	}];
}

@end
