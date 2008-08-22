//
//  TTTweetViewBox.h
//  TweetTweet
//
//  Created by Jeremy Knope on 6/15/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TTTweetViewBox : NSBox {
	IBOutlet NSCollectionViewItem *viewItem;
//	IBOutlet NSArrayController *tweetArrayController;
}

@property (readwrite, retain) NSCollectionViewItem *viewItem;

@end
