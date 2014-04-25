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

@end
