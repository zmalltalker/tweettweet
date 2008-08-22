//
//  TTImageCache.m
//  TweetTweet
//
//  Created by Jeremy Knope on 6/6/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "TTImageCache.h"
#import "AppController.h"

@implementation TTImageCache
static TTImageCache* sharedImageCache;

+ (TTImageCache *)sharedImageCache
{
	if (!sharedImageCache)
	{
		sharedImageCache = [[TTImageCache alloc] init];
	}
	return sharedImageCache;
}

/**
 * Consider storing images in ~/Library/Caches instead
 */
- (id)init {
	if(self = [super init]) {
		AppController *appDelegate = [[NSApplication sharedApplication] delegate];
		cacheFolder = [[[appDelegate applicationSupportFolder] stringByAppendingPathComponent:@"images"] retain];
		if ( ![[NSFileManager defaultManager] fileExistsAtPath:cacheFolder isDirectory:NULL] ) {
			[[NSFileManager defaultManager] createDirectoryAtPath:cacheFolder attributes:nil];
		}
	}
	return self;
}

- (void)dealloc {
	[cacheFolder release];
	[super dealloc];
}

- (NSImage *)imageForId:(NSInteger)imageId {
	NSString *imagePath = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.tiff", imageId]];
	if([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
		return [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
	}
	return nil;
}

- (void)storeImage:(NSImage *)anImage withId:(NSInteger)anId {
	NSString *imagePath = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.tiff", anId]];
	if(![[anImage TIFFRepresentation] writeToFile:imagePath atomically:NO]) {
		NSLog(@"Failed to store image: %@", imagePath);
	}
}

@end
