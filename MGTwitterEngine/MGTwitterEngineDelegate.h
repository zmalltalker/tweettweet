//
//  MGTwitterEngineDelegate.h
//  MGTwitterEngine
//
//  Created by Matt Gemmell on 16/02/2008.
//  Copyright 2008 Magic Aubergine.
//

#if TARGET_OS_ASPEN
	#import <Foundation/Foundation.h>
	#import <UIKit/UIKit.h>
#else
	#import <Cocoa/Cocoa.h>
#endif

@protocol MGTwitterEngineDelegate

- (void)requestSucceeded:(NSString *)requestIdentifier;
- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error;

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier;
- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)identifier;
- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier;
- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)identifier;

#if TARGET_OS_ASPEN
- (void)imageReceived:(UIImage *)image forRequest:(NSString *)identifier;
#else
- (void)imageReceived:(NSImage *)image forRequest:(NSString *)identifier;
#endif

@end
