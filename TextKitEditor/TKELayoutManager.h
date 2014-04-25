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
 @abstract The left and right inset to be applied to the line starting at the specified character index.
 */
- (UIEdgeInsets)insetsForLineStartingAtCharacterIndex:(NSUInteger)characterIndex;

@end
