//
//  TTTweet.h
//  TweetTweet
//
//  Created by Jeremy Knope on 6/2/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTUser;

@interface TTTweet :  NSManagedObject  
{
	NSAttributedString *displayContents;
}

@property (retain) NSDate * created_at;
@property (retain) NSNumber * favorited;
@property (retain) NSNumber * read;
@property (retain) NSNumber * reply_to_status_id;
@property (retain) NSNumber * reply_to_user_id;
@property (retain) NSString * source;
@property (retain) NSNumber * tweet_id;
@property (retain) NSString * text;
@property (retain) TTUser * user;
@property (retain) NSAttributedString *displayContents;

- (NSAttributedString *)linkifyText:(NSString *)originalContents;

@end
