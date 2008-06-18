//
//  AppController.m
//  TweetTweet
//
//  Created by Jeremy Knope on 3/27/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

#import "AppController.h"
#import "BCLengthLimitFormatter.h"
#import "EMKeychainProxy.h"
#import "EMKeychainItem.h"

@implementation AppController

@synthesize recentStatusesArray;

- (void)awakeFromNib
{
	BCLengthLimitFormatter *textSizeFormatter = [[BCLengthLimitFormatter alloc] initWithLimit:140];
	textSizeFormatter.lengthLimit = 140;
	[messageField setFormatter:textSizeFormatter];
	[messageField setDelegate:self];
	[statusesTable setRowHeight:60];
	
    storage = [[TweetStorage alloc] initWithManagedObjectContext:[self managedObjectContext]];
	storage.delegate = self;
	
	[GrowlApplicationBridge setGrowlDelegate:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO];
	[statusesArrayController setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"twitterUsername"];
	EMKeychainItem *keychainItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"TweetTweet" withUsername:username];
	NSString *password = [keychainItem password];
	if(!username || [username isEqualToString:@""] || !password || [password isEqualToString:@""]) {
		[[NSApplication sharedApplication] beginSheet:usernamePasswordWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
	else {
		[storage setUsername:username password:password];
		[self startTwitter];
	}
}

- (void)startTwitter {
	[self refreshTweets:self];
	NSNumber *refreshMinutes = [[NSUserDefaults standardUserDefaults] objectForKey:@"refreshMinutes"];
	if(!refreshMinutes) {
		refreshMinutes = [NSNumber numberWithInt:5];
		[[NSUserDefaults standardUserDefaults] setObject:refreshMinutes forKey:@"refreshMinutes"];
	}
	refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:([refreshMinutes intValue]*60) target:self selector:@selector(refreshTweets:) userInfo:nil repeats:YES] retain];
}

- (IBAction)cancelUsernamePassword:(id)sender {
	NSLog(@"Cancel!");
	[usernamePromptField setStringValue:@""];
	[passwordPromptField setStringValue:@""];
	[[NSApplication sharedApplication] endSheet:usernamePasswordWindow];
	[usernamePasswordWindow orderOut:self];
	[[NSApplication sharedApplication] terminate:self];
}

- (IBAction)submitUsernamePassword:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[usernamePromptField stringValue] forKey:@"twitterUsername"];
	if([savePasswordCheckbox state] == NSOnState) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"savePassword"];
		[[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:@"TweetTweet" withUsername:[usernamePromptField stringValue] password:[passwordPromptField stringValue]];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"savePassword"];
	}
	[[NSApplication sharedApplication] endSheet:usernamePasswordWindow];
	[usernamePasswordWindow orderOut:self];
	[storage setUsername:[usernamePromptField stringValue] password:[passwordPromptField stringValue]];
	[self startTwitter];
}

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"TweetTweet"];
}

/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"TweetTweetStorage.db"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}



- (void)dealloc {
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
	[refreshTimer release], refreshTimer = nil;
	if(preferencesController) {
		[preferencesController release], preferencesController = nil;
	}
    [super dealloc];
}

#pragma mark -

- (IBAction)sendTweet:(id)sender {
	NSString *message = [messageField stringValue];
	[messageField setEnabled:NO];
	[storage sendStatus:message];
	[progressIndicator startAnimation:nil];
	[errorField setStringValue:@""];
}

- (IBAction)replyToTweet:(id)sender {
	if([[statusesArrayController selectedObjects] count]) {
		TTTweet *tweet = [[statusesArrayController selectedObjects] objectAtIndex:0];
		[messageField setStringValue:[NSString stringWithFormat:@"@%@ ", tweet.user.screen_name]];
		[mainWindow makeFirstResponder:messageField];
	}
}

- (IBAction)directMessage:(id)sender {
	if([[statusesArrayController selectedObjects] count]) {
		TTTweet *tweet = [[statusesArrayController selectedObjects] objectAtIndex:0];
		[messageField setStringValue:[NSString stringWithFormat:@"d %@ ", tweet.user.screen_name]];
		[mainWindow makeFirstResponder:messageField];
	}
}

- (IBAction)markAllAsRead:(id)sender {
	[[statusesArrayController content] makeObjectsPerformSelector:@selector(setRead:) withObject:[NSNumber numberWithBool:YES]];
}

- (IBAction)refreshTweets:(id)sender {
	[progressIndicator startAnimation:self];
	[errorField setStringValue:@""];
	[storage sync];
}

- (IBAction)showPreferences:(id)sender {
	if(!preferencesController) {
		preferencesController = [[NSWindowController alloc] initWithWindowNibName:@"Preferences"];
	}
	[preferencesController showWindow:self];
}

#pragma mark -

- (void)controlTextDidChange:(NSNotification *)aNotification {
	if([[messageField stringValue] length] == 0) {
		[messageCounterField setStringValue:@""];
	}
	else {
		[messageCounterField setIntValue:140 - [[messageField stringValue] length]];
	}
}

- (void)tweetsUpdateFailedWithError:(NSString *)errorString {
	[progressIndicator stopAnimation:nil];
	[errorField setStringValue:errorString];
}

- (void)tweetsUpdated {
	[progressIndicator stopAnimation:nil];
}

- (void)tweetUpdateSucceeded {
	[messageField setStringValue:@""];
	[messageField setEnabled:YES];
	[progressIndicator stopAnimation:nil];
	[self controlTextDidChange:nil];
}

- (void)tweetUpdateFailedWithError:(NSString *)errorString {
	[messageField setEnabled:YES];
	[progressIndicator stopAnimation:nil];
	[errorField setStringValue:errorString];
}

- (void)receivedNewTweets:(NSArray *)newTweets {
	NSLog(@"%d new tweets!", [newTweets count]);
	NSInteger counter = 0;
	for(TTTweet *tweet in newTweets) {
		if(counter >= 5) {
			break;
		}
		[GrowlApplicationBridge
			notifyWithTitle:tweet.user.name
			description:tweet.text
			notificationName:@"New Tweet"
			iconData:[tweet.user.profileImage TIFFRepresentation]
			priority:0
			isSticky:NO
			clickContext:tweet];
		counter++;
	}
	if(counter < [newTweets count]) {
		[GrowlApplicationBridge
			notifyWithTitle:[NSString stringWithFormat:@"%d more tweets",[newTweets count] - counter]
			description:@"More tweets!"
			notificationName:@"New Tweet"
			iconData:nil
			priority:0
			isSticky:NO
			clickContext:nil];
	}
}
// should this be replaced by a KVO method on the array controller instead? instead
// TODO: also have to change this to handle NSCollectionView, KVO on array controller selection might work
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	if([[statusesArrayController selectedObjects] count] > 0) {
		TTTweet *tweet = [[statusesArrayController selectedObjects] objectAtIndex:0];
		tweet.read = [NSNumber numberWithBool:YES];
	}
}

#pragma mark Growl delegate methods

- (void)growlNotificationWasClicked:(id)clickContext {
	NSLog(@"We got a click");
	NSLog(@"Clicked on %@", clickContext);
}

@end
