//
//  TKECodeString.h
//  TextKitEditor
//
//  Created by Max Seelemann on 25.04.14.
//  Copyright (c) 2014 Max Seelemann. All rights reserved.
//

/*!
 @abstract Sting model class, exemplifying external storage of text.
 */
@interface TKECodeString : NSMutableString

/*!
 @abstract The types of code recognized by the string enumerator.
 */
typedef enum : NSUInteger {
	TKECodeTypeText,
	
	TKECodeTypeComment,
	TKECodeTypePragma,
	TKECodeTypeKeyword
} TKECodeType;


/*!
 @abstract Enumerates a passed range and detects various code types in it.
 @discussion For simplicity's sake, the passed range must be a paragraph range!
 */
- (void)enumerateCodeInRange:(NSRange)range usingBlock:(void (^)(NSRange range, TKECodeType type))block;


/*!
 @abstract Returns the paragraph number (aka line number) for the paragraph at the given index.
 */
- (NSUInteger)paragraphNumberForParagraphAtIndex:(NSUInteger)index;

@end
