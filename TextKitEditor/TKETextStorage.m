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


#pragma mark - Properties

- (void)setContent:(TKECodeString *)content
{
	_content = content;
	
	// Coalesce change notifications
	[self beginEditing];
	
	// Re-build string cache
	NSInteger oldLength = _cache.length;
	[_cache replaceCharactersInRange:NSMakeRange(0, oldLength) withString:_content];
	[self edited:NSTextStorageEditedCharacters range:NSMakeRange(0, oldLength) changeInLength:(NSInteger)_content.length - oldLength];
	
	// TODO: Update attributes
	
	// End coalescing change notifications
	[self endEditing];
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
	[super processEditing];
	// TODO: Compute some attributes.
}

@end
