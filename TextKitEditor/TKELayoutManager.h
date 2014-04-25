//
//  TKELayoutManager.h
//  TextKitEditor
//
//  Created by Max Seelemann on 25.04.14.
//  Copyright (c) 2014 Max Seelemann. All rights reserved.
//

/*!
 @abstract Layout manager performing additional magic in the code editor.
 */
@interface TKELayoutManager : NSLayoutManager

/*!
 @abstract Whether paragraph numbers should be shown or not.
 @discussion Defaults to NO.
 */
@property(nonatomic) BOOL showParagraphNumbers;

/*!
 @abstract The number of n's determining the width of a tab.
 @discussion Defaults to 2.
 */
@property(nonatomic) NSUInteger tabWidth;

/*!
 @abstract The multiple of the regaulr line height to be used.
 @discussion Defaults to 1.0, use regular line height.
 */
@property(nonatomic) CGFloat lineHeight;

/*!
 @abstract The left and right inset to be applied to the line starting at the specified character index.
 */
- (UIEdgeInsets)insetsForLineStartingAtCharacterIndex:(NSUInteger)characterIndex;

@end
