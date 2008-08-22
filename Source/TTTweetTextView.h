//
//  TTTweetTextView.h
//  TweetTweet
//
//  Created by Jeremy Knope on 7/8/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TTTweetTextView : NSTextView {
	id enterTarget;
	SEL enterAction;
}

- (void)setTarget:(id)target;
- (void)setAction:(SEL)selector;
@end
