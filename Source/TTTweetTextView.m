//
//  TTTweetTextView.m
//  TweetTweet
//
//  Created by Jeremy Knope on 7/8/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "TTTweetTextView.h"


@implementation TTTweetTextView
- (void)keyDown:(NSEvent *)theEvent {
	if([theEvent type] == NSKeyDown && [theEvent keyCode] == 36) {
		if(enterTarget && enterAction) {
			[enterTarget performSelector:enterAction withObject:self];
			return;
		}
	}
	[super keyDown:theEvent];
}

- (void)setTarget:(id)target {
	enterTarget = [target retain];
}

- (void)setAction:(SEL)selector {
	enterAction = selector;
}
@end
