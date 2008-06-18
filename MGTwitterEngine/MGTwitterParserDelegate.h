//
//  MGTwitterParserDelegate.h
//  MGTwitterEngine
//
//  Created by Matt Gemmell on 18/02/2008.
//  Copyright 2008 Magic Aubergine.
//

#if TARGET_OS_ASPEN
	#import <Foundation/Foundation.h>
	#import <UIKit/UIKit.h>
#else
	#import <Cocoa/Cocoa.h>
#endif

#import "MGTwitterRequestTypes.h"

@protocol MGTwitterParserDelegate

- (void)parsingSucceededForRequest:(NSString *)identifier 
                    ofResponseType:(MGTwitterResponseType)responseType 
                 withParsedObjects:(NSArray *)parsedObjects;

- (void)parsingFailedForRequest:(NSString *)requestIdentifier 
                 ofResponseType:(MGTwitterResponseType)responseType 
                      withError:(NSError *)error;

@end
