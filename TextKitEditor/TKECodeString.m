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

@end
