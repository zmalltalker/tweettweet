//
//  TweetStorage.h
//  TweetTweet
//
//  Created by Jeremy Knope on 5/30/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGTwitterEngine.h"
#import "TTTweet.h"
#import "TTUser.h"

/**
 * Delegate for being notified when twittery things happen
 * 
 */
@protocol TweetStorageDelegate
/**
 * Retrieval of latest tweets
 */
- (void)tweetsUpdated;
- (void)tweetsUpdateFailedWithError:(NSString *)errorString;

/**
 * For sending of new tweet
 */
- (void)tweetUpdateFailedWithError:(NSString *)errorString;
- (void)tweetUpdateSucceeded;

/**
 * Notification on fresh new tweets
 */
- (void)receivedNewTweets:(NSArray *)newTweets;
@end

@interface TweetStorage : NSObject {
    MGTwitterEngine *twitter;
	NSString *sendingIdentifier;
	NSManagedObjectContext *managedObjectContext;
	id <TweetStorageDelegate> delegate;
	
	NSMutableDictionary *storedUsers;
	NSMutableDictionary *storedTweets;
	
	NSMutableDictionary *fetchingImages;
}

@property (retain, readwrite) id delegate;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)setUsername:(NSString *)user password:(NSString *)pass;

- (BOOL)sendStatus:(NSString *)status;

- (void)storeStatus:(NSDictionary *)status;
- (TTUser *)storeUser:(NSDictionary *)user;
- (BOOL)isUserInformationDifferent:(NSDictionary *)userInfo fromUser:(TTUser *)oldUser;
- (BOOL)sync;
@end
