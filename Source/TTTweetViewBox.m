//
//  TTTweetViewBox.m
//  TweetTweet
//
//  Created by Jeremy Knope on 6/15/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "TTTweetViewBox.h"
#import "TTTweetTextField.h"

@implementation TTTweetViewBox

@synthesize viewItem;

+ (void)initialize {
	[self exposeBinding:@"viewItem"];
}

/**
 * We're only allowing hits to occur in the main text of a tweet
 */
- (NSView *)hitTest:(NSPoint)aPoint
{
	NSView *testView = [super hitTest:aPoint];
	if([testView isKindOfClass:[TTTweetTextField class]]) {
		return testView;
	}
	return nil;
}

@end
