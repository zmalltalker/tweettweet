//
//  BCLengthLimitFormatter.h
//  TweetTweet
//
//  Created by Jeremy Knope on 6/1/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BCLengthLimitFormatter : NSFormatter {
	NSInteger lengthLimit;
}

@property (assign, readwrite) NSInteger lengthLimit;

- (id)initWithLimit:(int)length;
@end
