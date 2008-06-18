//
//  MGTwitterHTTPURLConnection.h
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

#import "MGTwitterRequestTypes.h"

@interface MGTwitterHTTPURLConnection : NSURLConnection {
    NSMutableData *_data;                   // accumulated data received on this connection
    MGTwitterRequestType _requestType;      // general type of this request, mostly for error handling
    MGTwitterResponseType _responseType;    // type of response data expected (if successful)
    NSString *_identifier;
}

// Initializer
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate 
           requestType:(MGTwitterRequestType)requestType responseType:(MGTwitterResponseType)responseType;

// Data helper methods
- (void)resetDataLength;
- (void)appendData:(NSData *)data;

// Accessors
- (NSString *)identifier;
- (NSData *)data;
- (MGTwitterRequestType)requestType;
- (MGTwitterResponseType)responseType;
- (NSString *)description;

@end
