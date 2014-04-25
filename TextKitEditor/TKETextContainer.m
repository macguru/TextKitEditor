//
//  TKETextContainer.m
//  TextKitEditor
//
//  Created by Max Seelemann on 25.04.14.
//  Copyright (c) 2014 Max Seelemann. All rights reserved.
//

#import "TKETextContainer.h"

#import "TKELayoutManager.h"


@implementation TKETextContainer

- (CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect atIndex:(NSUInteger)characterIndex writingDirection:(NSWritingDirection)baseWritingDirection remainingRect:(CGRect *)remainingRect
{
	CGRect rect = [super lineFragmentRectForProposedRect:proposedRect atIndex:characterIndex writingDirection:baseWritingDirection remainingRect:remainingRect];
	
	// IMPORTANT: Inset width only, since setting a non-zero X coordinate kills the text system
	// Offset must be done *after layout computation* in UMLayoutManager's -setLineFragmentRect:forGlyphRange:usedRect:
	
	UIEdgeInsets insets = [(TKELayoutManager *)self.layoutManager insetsForLineStartingAtCharacterIndex: characterIndex];
	rect.size.width -= insets.left + insets.right;
	return rect;
}

@end
