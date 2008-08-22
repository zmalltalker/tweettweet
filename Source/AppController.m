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

@synthesize statusesArrayController, tweetsFilterPredicate, tweetsSortDescriptors;
- (id)init {
	if(self = [super init]) {
		tweetsSortDescriptors = [[NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO], nil] retain];
		
		self.tweetsFilterPredicate = [NSPredicate predicateWithFormat:@"created_at >= %@", [NSDate dateWithTimeIntervalSinceNow:-(60*60*24)]];
		statusesArrayController = [[NSArrayController alloc] init];
		[statusesArrayController setManagedObjectContext:[self managedObjectContext]];
		[statusesArrayController setEntityName:@"TTTweet"];
		[statusesArrayController fetch:self];
		[statusesArrayController setFilterPredicate:self.tweetsFilterPredicate];
		[statusesArrayController setSortDescriptors:tweetsSortDescriptors];
	}
	return self;
}

- (void)awakeFromNib
{
	BCLengthLimitFormatter *textSizeFormatter = [[BCLengthLimitFormatter alloc] initWithLimit:140];
	textSizeFormatter.lengthLimit = 140;
	//[messageField setFormatter:textSizeFormatter];
	//[messageField setDelegate:self];
	[messageView setTarget:self];
	[messageView setAction:@selector(sendTweet:)];
	
    storage = [[TweetStorage alloc] initWithManagedObjectContext:[self managedObjectContext]];
	storage.delegate = self;
	
	[GrowlApplicationBridge setGrowlDelegate:self];
	[statusesArrayController addObserver:self forKeyPath:@"selection" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	/*NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO];
	[statusesArrayController setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	*/
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
		EMKeychainItem *keychainItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"TweetTweet" withUsername:[usernamePromptField stringValue]];
		if(!keychainItem) {
			[[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:@"TweetTweet" withUsername:[usernamePromptField stringValue] password:[passwordPromptField stringValue]];
		}
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
	[tweetsSortDescriptors release];
    [super dealloc];
}

#pragma mark -

- (IBAction)sendTweet:(id)sender {
	NSString *message = [[messageView textStorage] string];
	//[messageView setEnabled:NO];
	[storage sendStatus:message];
	[progressIndicator startAnimation:nil];
	[errorField setStringValue:@""];
	[mainWindow makeFirstResponder:tweetsCollectionView];
}

- (IBAction)replyToTweet:(id)sender {
	if([[statusesArrayController selectedObjects] count]) {
		TTTweet *tweet = [[statusesArrayController selectedObjects] objectAtIndex:0];
		NSAttributedString *msg = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@ ", tweet.user.screen_name]];
		[[messageView textStorage] setAttributedString:[msg autorelease]];
		[mainWindow makeFirstResponder:messageView];
	}
}

- (IBAction)directMessage:(id)sender {
	if([[statusesArrayController selectedObjects] count]) {
		TTTweet *tweet = [[statusesArrayController selectedObjects] objectAtIndex:0];
		NSAttributedString *msg = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"d %@ ", tweet.user.screen_name]];
		[[messageView textStorage] setAttributedString:msg];
		[mainWindow makeFirstResponder:messageView];
	}
}

- (IBAction)markAllAsRead:(id)sender {
	[[statusesArrayController content] makeObjectsPerformSelector:@selector(setRead:) withObject:[NSNumber numberWithBool:YES]];
}

- (IBAction)refreshTweets:(id)sender {
	self.tweetsFilterPredicate = [NSPredicate predicateWithFormat:@"created_at >= %@", [NSDate dateWithTimeIntervalSinceNow:-(60*60*24)]];
	[statusesArrayController setFilterPredicate:self.tweetsFilterPredicate];
	[progressIndicator startAnimation:self];
	[errorField setStringValue:@""];
	[storage sync];
}

- (IBAction)showPreferences:(id)sender {
	NSLog(@"In TweetsArrayController: %i", [[statusesArrayController arrangedObjects] count]);
	if(!preferencesController) {
		preferencesController = [[NSWindowController alloc] initWithWindowNibName:@"Preferences"];
	}
	[preferencesController showWindow:self];
}

#pragma mark -

- (void)controlTextDidChange:(NSNotification *)aNotification {
	if([[[messageView textStorage] string] length] == 0) {
		[messageCounterField setStringValue:@""];
	}
	else {
		[messageCounterField setStringValue:[NSString stringWithFormat:@"%i chars",(140 - [[[messageView textStorage] string] length])]];
	}
}

#pragma mark -

- (void)tweetsUpdateFailedWithError:(NSString *)errorString {
	[progressIndicator stopAnimation:nil];
	[errorField setStringValue:errorString];
}

- (void)tweetsUpdated {
	[progressIndicator stopAnimation:nil];
	NSLog(@"Done updating, predicate: %@", [statusesArrayController filterPredicate]);
}

- (void)tweetUpdateSucceeded {
	[[messageView textStorage] setAttributedString:[[[NSAttributedString alloc] init] autorelease]];
	//[messageView setEnabled:YES];
	[progressIndicator stopAnimation:nil];
	[self controlTextDidChange:nil];
}

- (void)tweetUpdateFailedWithError:(NSString *)errorString {
	//[messageView setEnabled:YES];
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
			clickContext:tweet.tweet_id];
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

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqualToString:@"selection"] && [[statusesArrayController selectedObjects] count] > 0) {
		TTTweet *tweet = [[statusesArrayController selectedObjects] objectAtIndex:0];
		if([tweet.read boolValue]) {
			return;
		}
		tweet.read = [NSNumber numberWithBool:YES];
	}
}

#pragma mark Growl delegate methods

- (void)growlNotificationWasClicked:(id)clickContext {
	NSLog(@"Clicked on %@", clickContext);
}

@end
