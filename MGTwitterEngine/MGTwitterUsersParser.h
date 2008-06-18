//
//  MGTwitterUsersParser.h
//  MGTwitterEngine
//
//  Created by Matt Gemmell on 19/02/2008.
//  Copyright 2008 Magic Aubergine.
//

#if TARGET_OS_ASPEN
	#import <Foundation/Foundation.h>
	#import <UIKit/UIKit.h>
#else
	#import <Cocoa/Cocoa.h>
#endif

#import "MGTwitterStatusesParser.h"

@interface MGTwitterUsersParser : MGTwitterStatusesParser {

}

@end
