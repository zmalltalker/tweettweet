//
//  MGTwitterXMLParser.h
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

#import "MGTwitterParserDelegate.h"

@interface MGTwitterXMLParser : NSObject {
    __weak NSObject <MGTwitterParserDelegate> *delegate; // weak ref
    NSString *identifier;
    MGTwitterRequestType requestType;
    MGTwitterResponseType responseType;
    NSData *xml;
    NSMutableArray *parsedObjects;
    NSXMLParser *parser;
    __weak NSMutableDictionary *currentNode;
    NSString *lastOpenedElement;
}

+ (id)parserWithXML:(NSData *)theXML delegate:(NSObject *)theDelegate 
connectionIdentifier:(NSString *)identifier requestType:(MGTwitterRequestType)reqType 
       responseType:(MGTwitterResponseType)respType;
- (id)initWithXML:(NSData *)theXML delegate:(NSObject *)theDelegate 
connectionIdentifier:(NSString *)identifier requestType:(MGTwitterRequestType)reqType 
     responseType:(MGTwitterResponseType)respType;

- (NSString *)lastOpenedElement;
- (void)setLastOpenedElement:(NSString *)value;

- (void)addSource;

@end
