//
//  TTTweetTextField.m
//  TweetTweet
//
//  Created by Jeremy Knope on 6/23/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "TTTweetTextField.h"
#import "TTTweetViewBox.h"

@implementation TTTweetTextField
//- (void)mouseDown:(NSEvent *)theEvent {
//	[super mouseDown:theEvent];
//}

- (void)mouseDown:(NSEvent *)theEvent {
	TTTweetViewBox *tweetView = (TTTweetViewBox *)[[self superview] superview];
	if(tweetView.viewItem) {
		[tweetView.viewItem setSelected:YES];
	}
	[super mouseDown:theEvent];
}
@end
