//
//  TKETextStorage.h
//  TextKitEditor
//
//  Created by Max Seelemann on 25.04.14.
//  Copyright (c) 2014 Max Seelemann. All rights reserved.
//

@class TKECodeString;

/*!
 @abstract Text storage performing syntax highlighting with the use of a TKECodeString.
 */
@interface TKETextStorage : NSTextStorage

/*!
 @abstract The code string to be used as the text storage's contents.
 */
@property(nonatomic) TKECodeString *content;

/*!
 @abstract The font to be used in the text storage.
 */
@property(nonatomic) UIFont *font;


/*!
 @abstract Returns the paragraph number (aka line number) for the paragraph at the given index.
 */
- (NSUInteger)paragraphNumberForParagraphAtIndex:(NSUInteger)index;

@end
