//
//  TTTweetWindowController.m
//  TweetTweet
//
//  Created by Jeremy Knope on 6/15/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "TTTweetWindowController.h"


@implementation TTTweetWindowController
- (NSString *)windowNibName
{
    return @"TweetsWindow";
}

// Once window is loaded, either wizard view or tweets view could be loaded into window.
- (void)windowDidLoad {
	NSLog(@"We have loaded!");
}
@end
