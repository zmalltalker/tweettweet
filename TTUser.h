//
//  TTUser.h
//  TweetTweet
//
//  Created by Jeremy Knope on 6/2/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTTweet;

@interface TTUser : NSManagedObject {
	NSImage *profileImage;
}
@property (retain) NSString * profileDescription;
@property (retain) NSNumber * followers;
@property (retain) NSString * image_url;
@property (retain) NSString * location;
@property (retain) NSString * name;
@property (retain) NSString * screen_name;
@property (retain) NSString * url;
@property (retain) NSNumber * user_id;
@property (retain) NSSet* tweets;

@property (retain) NSImage *profileImage;

- (NSSize)resizeSize:(NSSize)originalSize within:(NSSize)constraints;

/*- (void)addTweetsObject:(TTTweet *)value;
- (void)removeTweetsObject:(TTTweet *)value;
- (void)addTweets:(NSSet *)value;
- (void)removeTweets:(NSSet *)value;*/

@end
