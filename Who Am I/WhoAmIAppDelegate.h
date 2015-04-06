//
//  WhoAmIAppDelegate.h
//  Who Am I
//
//  Created by Larry Wells on 5/24/14.
//  Copyright (c) 2014 Larry Wells. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WhoAmIAppDelegate : NSObject <NSApplicationDelegate>

@property (readwrite, retain) IBOutlet NSMenu *statusMenu;
@property (readwrite, retain) IBOutlet NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenuItem *statusItem_IP_Address;    //IP Address(S)
@property (weak) IBOutlet NSMenuItem *statusItem_host_name;     //Computer name
@property (unsafe_unretained) IBOutlet NSWindow *preferences_Window;
@property (weak) IBOutlet NSButton *chk_runatstartup;
@property (weak) IBOutlet NSButton *chk_useNotifications;
@property (weak) NSUserDefaults *userSettings;
@property (weak) NSMutableArray *filteredIPAddresses;


- (IBAction)menuAction:(id)sender;
- (IBAction)menuClicked:(id)sender;

@end
