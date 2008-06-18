//
//  TTTweet.m
//  TweetTweet
//
//  Created by Jeremy Knope on 6/2/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "TTTweet.h"
#import "TTUser.h"
#import "RegexKitLite.h"
#import "RKLMatchEnumerator.h"

@implementation TTTweet

@dynamic created_at;
@dynamic favorited;
@dynamic read;
@dynamic reply_to_status_id;
@dynamic reply_to_user_id;
@dynamic source;
@dynamic tweet_id;
@dynamic text;
@dynamic user;

- (void)dealloc {
	if(displayContents) {
		[displayContents release];
		displayContents = nil;
	}
	[super dealloc];
}

- (void)setDisplayContents:(NSAttributedString *)newContents {
	displayContents = [newContents retain];
}

- (NSAttributedString *)displayContents {
	if(!displayContents) {
		//NSString *html = [NSString stringWithFormat:@"%@", self.text];
		//self.displayContents = [[[NSAttributedString alloc] initWithHTML:[html dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:nil] autorelease];
		self.displayContents = [self linkifyText:self.text];
	}
	return displayContents;
}

/**
 * Processes the given string, linkifying usernames, and eventually URLs if we need to
 */
- (NSAttributedString *)linkifyText:(NSString *)originalContents {
	NSMutableAttributedString *outString = [[[NSMutableAttributedString alloc] initWithString:originalContents] autorelease];
	NSString     *regexString     = @"@\\w+";
	NSUInteger location = 0;
	while(location != NSNotFound) { // copied this chunk from the RKLMatchEnumerator, had to set location it seems though... 
		NSRange searchRange  = NSMakeRange(location, [originalContents length] - location);
		NSRange matchedRange = [originalContents rangeOfRegex:regexString inRange:searchRange];
		location = NSMaxRange(matchedRange) + ((matchedRange.length == 0) ? 1 : 0);

		if(matchedRange.location != NSNotFound) {
			[outString addAttribute:NSLinkAttributeName value:[NSString stringWithFormat:@"http://twitter.com/%@",[originalContents substringWithRange:NSMakeRange(matchedRange.location+1,matchedRange.length-1)]] range:matchedRange];
			[outString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:matchedRange];
			[outString addAttribute:NSUnderlineStyleAttributeName value: [NSNumber numberWithInt:1] range:matchedRange];
		}
		else {
			location = matchedRange.location;
		}
	}
	[outString fixAttributesInRange:NSMakeRange(0, [outString length])];
	return [[[NSAttributedString alloc] initWithAttributedString:outString] autorelease]; // there a way to do immutable copy?
}
@end
