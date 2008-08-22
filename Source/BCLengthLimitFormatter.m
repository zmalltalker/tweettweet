//
//  BCLengthLimitFormatter.m
//  TweetTweet
//
//  Created by Jeremy Knope on 6/1/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "BCLengthLimitFormatter.h"


@implementation BCLengthLimitFormatter

@synthesize lengthLimit;

- (id)initWithLimit:(int)length {
	if(self = [super init]) {
		lengthLimit = length;
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (NSString *)stringForObjectValue:(id)anObject {
	return anObject;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
	*anObject = string;
	return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr 
	   proposedSelectedRange:(NSRangePointer)proposedSelRangePtr 
			  originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error {
	if(([*partialStringPtr length] > [origString length] && [origString length] >= lengthLimit) || ([*partialStringPtr length] > lengthLimit)) {
		return NO;
	}
	return YES;
}

@end
