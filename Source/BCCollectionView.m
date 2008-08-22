//
//  BCCollectionView.m
//  TweetTweet
//
//  Created by Jeremy Knope on 6/23/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "BCCollectionView.h"
#import "TTTweetViewBox.h"

@implementation BCCollectionView

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object {
	NSCollectionViewItem *newItem = [super newItemForRepresentedObject:object];
	TTTweetViewBox *view = (TTTweetViewBox *)[newItem view];
	view.viewItem = newItem;
	return newItem;
}

@end
