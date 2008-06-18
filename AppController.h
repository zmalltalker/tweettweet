//
//  AppController.h
//  TweetTweet
// Controls the app and stuff
//
//  Created by Jeremy Knope on 3/27/08.
//  Copyright 2008 Buttered Cat. All rights reserved.
//

// use is.gd: http://is.gd/api.php?longurl=http://www.example.com

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "TweetStorage.h"

@interface AppController : NSObject <TweetStorageDelegate,GrowlApplicationBridgeDelegate> {
	TweetStorage *storage;
	NSArray *recentStatusesArray;
	IBOutlet NSTableView *statusesTable;
	IBOutlet NSArrayController *statusesArrayController;
	
	IBOutlet NSTextField *messageField;
	IBOutlet NSTextField *messageCounterField;
	IBOutlet NSTextField *errorField;
	IBOutlet NSProgressIndicator *progressIndicator;
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	NSTimer *refreshTimer;
	
	NSWindowController *preferencesController;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *usernamePasswordWindow;
	IBOutlet NSTextField *usernamePromptField;
	IBOutlet NSTextField *passwordPromptField;
	IBOutlet NSButton *savePasswordCheckbox;
}
@property(readwrite, retain) NSArray *recentStatusesArray;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

- (void)startTwitter;

- (NSString *)applicationSupportFolder;

- (IBAction)cancelUsernamePassword:(id)sender;
- (IBAction)submitUsernamePassword:(id)sender;

- (IBAction)sendTweet:(id)sender;
- (IBAction)replyToTweet:(id)sender;
- (IBAction)directMessage:(id)sender;
- (IBAction)markAllAsRead:(id)sender;
- (IBAction)refreshTweets:(id)sender;

- (IBAction)showPreferences:(id)sender;

- (void)controlTextDidChange:(NSNotification *)aNotification;

@end
