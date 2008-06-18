//
//  NSString+UUID.m
//  MGTwitterEngine
//
//  Created by Matt Gemmell on 16/09/2007.
//  Copyright 2007 Magic Aubergine.
//

#import "NSString+UUID.h"


@implementation NSString (UUID)


+ (NSString*)stringWithNewUUID
{
    // Create a new UUID
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    // Get the string representation of the UUID
    NSString *newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [newUUID autorelease];
}


@end
