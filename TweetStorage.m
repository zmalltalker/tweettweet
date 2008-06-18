//
//  TweetStorage.m
//  TweetTweet
//
//  Created by Jeremy Knope on 5/30/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "TweetStorage.h"
#import "TTImageCache.h"

@interface NSManagedObject(TTSync)
@property (retain) NSDate *last_sync;
@end


@implementation TweetStorage

@synthesize delegate;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc {
	if(self = [super init]) {
		managedObjectContext = [moc retain];
		twitter = [[MGTwitterEngine alloc] initWithDelegate:self];
		fetchingImages = [[NSMutableDictionary dictionary] retain];
	}
	return self;
}

- (void)setUsername:(NSString *)user password:(NSString *)pass {
	[twitter setUsername:user password:pass];
}

- (id)init {
	return nil;
}

- (BOOL)sync {
	NSDate *last_sync = [NSDate distantPast];
    if([last_sync timeIntervalSinceNow] < -(5 * 60)) {
		NSLog(@"Calling twitter!");
		storedUsers = [[NSMutableDictionary dictionary] retain];
		storedTweets = [[NSMutableDictionary dictionary] retain]; 
        [twitter getFollowedTimelineFor:nil since:nil startingAtPage:0];
		//[twitter getRepliesStartingAtPage:0];
    }
	return YES;
}

- (BOOL)sendStatus:(NSString *)status {
	NSString *cleanStatus = [status stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSRange typeCheck = [cleanStatus rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
	if(!NSEqualRanges(typeCheck, NSMakeRange(NSNotFound, 0))) {
		if([[cleanStatus substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"d"]) {
			NSRange usernameRange = [[cleanStatus substringFromIndex:typeCheck.location+1] rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
			NSString *user = [cleanStatus substringWithRange:NSMakeRange(typeCheck.location+typeCheck.length, usernameRange.location)];
			NSString *dirMsg = [[cleanStatus substringFromIndex:typeCheck.location+1] substringFromIndex:usernameRange.location+usernameRange.length];
			//NSLog(@"direct to '%@' msg: '%@'", user, dirMsg);
			sendingIdentifier = [twitter sendDirectMessage:dirMsg to:user];
		}
		else if([[cleanStatus substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"@"] && [[cleanStatus substringWithRange:NSMakeRange(0, typeCheck.location)] length] > 1) {
			sendingIdentifier = [twitter sendUpdate:cleanStatus inReplyTo:[cleanStatus substringWithRange:NSMakeRange(1, typeCheck.location)]];
		}
		else {
			sendingIdentifier = [twitter sendUpdate:cleanStatus];
		}
	}
	else if([cleanStatus length] > 0) {
		sendingIdentifier = [twitter sendUpdate:status];
	}
	[sendingIdentifier retain];
	return YES;
}

- (void)dealloc {
    [twitter release];
	[managedObjectContext release];
	if(storedUsers) {
		[storedUsers release], storedUsers = nil;
	}
	if(storedTweets) {
		[storedTweets release], storedTweets = nil;
	}
    [super dealloc];
}

- (void)storeStatus:(NSDictionary *)status {
	NSNumber *tweetId = [NSNumber numberWithInt:[[status objectForKey:@"id"] intValue]];
	TTUser *user = [self storeUser:[status objectForKey:@"user"]]; // we want to keep users up-to-date
	if([storedTweets objectForKey:tweetId]) {
		NSLog(@"Already stored tweet in temporary dictionary");
		return;
	}
	else {
		NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TTTweet" inManagedObjectContext:managedObjectContext];
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:entityDescription];
		 
		// Get last record by looking for lesser odometer readingss
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tweet_id = %@", tweetId];
		[request setPredicate:predicate];
		
		NSError *error = nil;
		NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
		if (array == nil) {
			NSLog(@"Error: %@", error); // Deal with error...
			return;
		}
		else if([array count] > 0) {
			//NSLog(@"TTTweet Already stored in CoreData");
			return; // [array objectAtIndex:0];
		}
		else { // create new one
			TTTweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:@"TTTweet" inManagedObjectContext:managedObjectContext];
			tweet.created_at = [status objectForKey:@"created_at"];
			tweet.favorited = [[status objectForKey:@"favorited"] isEqualToString:@"1"] ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
			tweet.reply_to_status_id = [NSNumber numberWithInt:[[status objectForKey:@"reply_to_status_id"] intValue]];
			tweet.reply_to_user_id = [NSNumber numberWithInt:[[status objectForKey:@"reply_to_user_id"] intValue]];
			tweet.source = [status objectForKey:@"source"];
			tweet.tweet_id = tweetId;
			tweet.text = [status objectForKey:@"text"];
			tweet.user = user;
			[storedTweets setObject:tweet forKey:tweetId];
		}
	}
}

- (TTUser *)storeUser:(NSDictionary *)userInfo {
	NSNumber *userId = [NSNumber numberWithInt:[[userInfo objectForKey:@"id"] intValue]];
	if([storedUsers objectForKey:userId]) {
		return [storedUsers objectForKey:userId];
	}
	else {
		TTUser *user, *oldUser;
		NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TTUser" inManagedObjectContext:managedObjectContext];
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:entityDescription];
		 
		// Get last record by looking for lesser odometer readingss
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(user_id = %@)", userId];
		[request setPredicate:predicate];
		 
		NSError *error = nil;
		NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
		if (array == nil) {
			NSLog(@"Error: %@", error); // Deal with error...
			return nil;
		}
		else if([array count] >  0) {
			oldUser = user = [array objectAtIndex:0];
		}
		else {
			user = [NSEntityDescription insertNewObjectForEntityForName:@"TTUser" inManagedObjectContext:managedObjectContext];
			oldUser = nil;
		}
		if(!oldUser || ![self isUserInformationDifferent:userInfo fromUser:oldUser]) {
			user.user_id = userId;
			user.screen_name = [userInfo objectForKey:@"screen_name"];
			user.name = [userInfo objectForKey:@"name"];
			user.image_url = [userInfo objectForKey:@"profile_image_url"];
			user.location = [userInfo objectForKey:@"location"];
			user.profileDescription = [userInfo objectForKey:@"description"];
			user.url = [userInfo objectForKey:@"url"];
			user.followers = [NSNumber numberWithInt:[[userInfo objectForKey:@"followers_count"] intValue]];
			[storedUsers setObject:user forKey:userId];
			if(!oldUser || ![user.image_url isEqualToString:[oldUser image_url]] || ![[TTImageCache sharedImageCache] imageForId:[user.user_id intValue]]) {
				[fetchingImages setObject:user forKey:[twitter getImageAtURL:user.image_url]];
			}
		}
		return user;
	}
	return nil;
}

- (BOOL)isUserInformationDifferent:(NSDictionary *)userInfo fromUser:(TTUser *)oldUser {
	if(![oldUser.url isEqualToString:[userInfo objectForKey:@"url"]] || 
				![oldUser.name isEqualToString:[userInfo objectForKey:@"name"]] || 
				![oldUser.screen_name isEqualToString:[userInfo objectForKey:@"screen_name"]] ||
				![oldUser.image_url isEqualToString:[userInfo objectForKey:@"profile_image_url"]] ||
				![oldUser.location isEqualToString:[userInfo objectForKey:@"location"]]
				) {
		return YES;
	}
	return NO;
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate methods


- (void)requestSucceeded:(NSString *)requestIdentifier
{
	if(sendingIdentifier && [requestIdentifier isEqualToString:sendingIdentifier]) {
		[delegate tweetUpdateSucceeded];
		[sendingIdentifier release];
	}
	else {
		[delegate tweetsUpdated];
	}
}


- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error
{
    NSLog(@"Twitter request failed! (%@) Error: %@ (%@)", 
          requestIdentifier, 
          [error localizedDescription], 
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	NSString *errorString;
	switch([error code]) {
		case 400:
			errorString = [NSString stringWithString:@"Rate limit exceeded for the hour"];
			break;
		case 401:
			errorString = [NSString stringWithString:@"Unauthorized: Invalid username/password"];
			break;
		case 502:
			errorString = [NSString stringWithString:@"Twitter is down/under maintenance"];
			break;
		default:
			errorString = [error localizedDescription];
	}
	
	if([sendingIdentifier isEqualToString:requestIdentifier]) {
		[delegate tweetUpdateFailedWithError:errorString];
	} else {
		[delegate tweetsUpdateFailedWithError:errorString];
	}
}


- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier
{
	for (NSDictionary *status in statuses) {
		[self storeStatus:status]; // stores tweet if it hasn't been
	}
	NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	else {
		[delegate receivedNewTweets:[storedTweets allValues]];
		[storedTweets removeAllObjects];
		[storedUsers removeAllObjects];
	}
	[delegate tweetsUpdated];
}


- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)identifier
{
    NSLog(@"Got direct messages:\r%@", messages);
	
}


- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier
{
    NSLog(@"Got user info:\r%@", userInfo);
}


- (void)imageReceived:(NSImage *)image forRequest:(NSString *)identifier
{
	TTUser *user = [fetchingImages objectForKey:identifier];
	[[TTImageCache sharedImageCache] storeImage:image withId:[user.user_id intValue]];
	user.profileImage = image;
}

@end
