//
//  AppDelegate.m
//  Boot Manager
//
//  Created by Jeremy Knope on 7/12/07.
//  Copyright 2009 Buttered Cat Software. All rights reserved.
//

#import "QBAppDelegate.h"
#import "QBVolumeManager.h"
#import "QBPreferencesController.h"
#import "MainWindowController.h"
#import "BCSystemInfo.h"
#import "BCAboutBox.h"

@implementation QBAppDelegate

static void * const kShowStatusIconContext = (void *)&kShowStatusIconContext;
//static void * const kShowIconInDockContext = (void *)&kShowIconInDockContext;

+ (void)initialize {
    if (self == [QBAppDelegate class]) {
        NSDictionary *defaults = @{
                                   @"ShowIconInDock": @(YES),
                                   @"ShowStatusIcon": @(YES),
                                   @"ShowOSXBuildNumber": @(NO),
                                   };
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
															  forKeyPath:@"values.ShowStatusIcon"
																 options:0
																 context:kShowStatusIconContext];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == kShowStatusIconContext) {
        [self setupStatusItem];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setupStatusItem {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowStatusIcon"]) {
        if (!self.statusItem) {
            self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24.0f];
            NSImage *statusImage = [NSImage imageNamed:@"StatusItemIcon"];
            [statusImage setTemplate:YES];
            [self.statusItem setImage:statusImage];
            [self.statusItem setHighlightMode:YES];
            [self.statusItem setMenu:self.statusMenu];
        }
    } else {
        if (self.statusItem) {
            [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
            self.statusItem = nil;
        }
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self setupStatusItem];
    
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowIconInDock"]) {
		[[self.mainWindowController window] makeKeyAndOrderFront:nil];
    }
		
	self.volumeManager = [[QBVolumeManager alloc] init];
	[self.mainWindowController setVolumeManager:self.volumeManager];
}

- (void)dealloc
{
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:@"values.ShowStatusIcon" context:kShowStatusIconContext];
}

- (IBAction)showAboutWindow:(id)sender
{
	if(!self.aboutBox) {
		self.aboutBox = [[BCAboutBox alloc] init];
		self.aboutBox.logoImageName = @"BootManager-logo";
	}
	[self.aboutBox display:sender];
}

- (IBAction)sendFeedback:(id)sender
{
	NSURL *url = [NSURL URLWithString:@"https://github.com/abdyfranco/boot-manager"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)showApplicationWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://abdyfran.co/projects/boot-manager"]];
}

- (IBAction)showCompanyWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://abdyfran.co/"]];
}

- (IBAction)showPreferences:(id)sender
{
	if(!self.preferencesController)
		self.preferencesController = [[QBPreferencesController alloc] init];
	
	[NSApp activateIgnoringOtherApps:YES]; // needed when in background mode
	[self.preferencesController showWindow:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowStatusIcon"]);
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
{
    return (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowStatusIcon"]);
}

#pragma mark -


@end
