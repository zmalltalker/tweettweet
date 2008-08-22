//
//  TTUser.m
//  TweetTweet
//
//  Created by Jeremy Knope on 6/2/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "TTUser.h"
#import "TTImageCache.h"

@implementation TTUser
@dynamic profileDescription;
@dynamic followers;
@dynamic image_url;
@dynamic location;
@dynamic name;
@dynamic screen_name;
@dynamic url;
@dynamic user_id;
@dynamic tweets;

- (NSImage *)profileImage {
	NSImage *cachedImage = [[TTImageCache sharedImageCache] imageForId:[self.user_id intValue]];
	if(!profileImage && cachedImage) {
		//[cachedImage resizeWithin:NSMakeSize(52, 52) enlarge:YES];
		self.profileImage = cachedImage;
	}
	else if(!profileImage) { // solve this below, we probably can remove it actually, doesn't work to return nil for some reason
		NSLog(@"Pulling from URL due to empty cache");
		profileImage = [[[NSImage alloc] initByReferencingURL:[NSURL URLWithString:self.image_url]] autorelease];
		if([profileImage isValid]) {
			//[profileImage setSize:[self resizeSize:[profileImage size] within:NSMakeSize(55, 55)]];
			self.profileImage = profileImage;
		}
		else {
			NSLog(@"Invalid image for URL: %@", self.image_url);
			profileImage = nil;
		}
	}
	return profileImage;
}

/*

$x_ratio = $max_width / $width;
		$y_ratio = $max_height / $height;
		if(($width <= $max_width) && ($height <= $max_height)) {
			$tn_width = $width;
			$tn_height = $height;
		}
		elseif(($x_ratio * $height) < $max_height) {
			$tn_height = ceil($x_ratio * $height);
			$tn_width = $max_width;
		}
		else {
			$tn_width = ceil($y_ratio * $width);
			$tn_height = $max_height;
		}
*/
// move this to NSImage category
- (NSSize)resizeSize:(NSSize)originalSize within:(NSSize)constraints {
	NSSize newSize;
	CGFloat xRatio = constraints.width / originalSize.width;
	CGFloat yRatio = constraints.height / originalSize.height;
	if(originalSize.width <= constraints.width && originalSize.height <= constraints.height) { // if both are within
		if(originalSize.width > originalSize.height) {
			newSize.width = constraints.width;
			newSize.height = xRatio * originalSize.height;
		}
		else {
			newSize.height = constraints.height;
			newSize.width = yRatio * originalSize.width;
		}
		//newSize.width = originalSize.width;
		//newSize.height = originalSize.height;
	}
	else if((xRatio * originalSize.height) < constraints.height) {
		newSize.height = xRatio * originalSize.height;
		newSize.width = constraints.width;
	}
	else {
		newSize.width = yRatio * originalSize.width;
		newSize.height = constraints.height;
	}
	return newSize;
}

- (void)setProfileImage:(NSImage *)newImage {
	profileImage = [newImage retain];
}

@end
