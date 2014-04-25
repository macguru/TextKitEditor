//
//  TKELayoutManager.m
//  TextKitEditor
//
//  Created by Max Seelemann on 25.04.14.
//  Copyright (c) 2014 Max Seelemann. All rights reserved.
//

#import "TKELayoutManager.h"


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


#pragma mark - Layout

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
	// Just a little bit more line spacing everywhere -- 10%
	return 0.1 * rect.size.height;
}

@end
