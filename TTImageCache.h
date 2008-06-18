//
//  TTImageCache.h
//  TweetTweet
//
//  Created by Jeremy Knope on 6/6/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTImageCache : NSObject {
	NSString *cacheFolder;
}

+ (TTImageCache *)sharedImageCache;

- (NSImage *)imageForId:(NSInteger)imageId;
- (void)storeImage:(NSImage *)anImage withId:(NSInteger)anId;
@end
