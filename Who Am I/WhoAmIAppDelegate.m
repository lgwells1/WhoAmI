//
//  WhoAmIAppDelegate.m
//  Who Am I
//
//  Created by Larry Wells on 5/24/14.
//  Copyright (c) 2015 Larry Wells. All rights reserved.
//

#import "WhoAmIAppDelegate.h"

@implementation WhoAmIAppDelegate
@synthesize statusMenu;
@synthesize statusItem;
@synthesize statusItem_IP_Address;
@synthesize statusItem_host_name;
@synthesize preferences_Window;
@synthesize chk_runatstartup;
@synthesize chk_useNotifications;
@synthesize userSettings;
@synthesize filteredIPAddresses;



- (void)awakeFromNib
{
    
    NSString *whoamiPlist = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/LaunchAgents/com.WhoAmI.plist"];
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage *menuIcon = [NSImage imageNamed:@"computer"];
    NSImage *highlightIcon = [NSImage imageNamed:@"computer"];
    [highlightIcon setTemplate:YES]; // Allows the correct highlighting of the icon when the menu is clicked.
    
    [[self statusItem] setImage:menuIcon];
    [[self statusItem] setAlternateImage:highlightIcon];
    [[self statusItem] setMenu:[self statusMenu]];
    [[self statusItem] setHighlightMode:YES];
    [self setMenuItemImagesToTemplates];
    
    
    //Check NSUserDefaults and set chkboxes accordingly
    userSettings = [NSUserDefaults standardUserDefaults];
    bool checkUseNotifications = [userSettings boolForKey:@"useNotifications"];
    if (checkUseNotifications == YES)
    {
        [chk_useNotifications setState:1];
    }
    else
    {
        [chk_useNotifications setState:0];
    }
    
    
    
    
    //Set chkbox checked or not
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:whoamiPlist])
    {
        [chk_runatstartup setState:1];
    }
    else
    {
        [chk_runatstartup setState:0];
    }
    
    
    
}
//Garbage?
-(IBAction)menuAction:(id)sender
{
    NSLog(@"menuAction: ");
}
//Garbage?
-(IBAction)menuClicked:(id)sender
{
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSTimer *timerCounter = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateMenuItems) userInfo:nil repeats: YES]; //make repeats YES
    NSLog(@"%@", timerCounter);     //No use other than to silence unused variable warning while testing :-)
    
}

//Exit Who AM I when clicked
- (IBAction)exitApplication:(NSMenuItem *)sender
{
    [[NSApplication sharedApplication] terminate:nil];
}


//When Timer fires off update all items in menu
- (void) updateMenuItems
{
    
    //Get Local Computer Name
    [self createIPAddressMenuItem:[[NSHost currentHost] localizedName]];
    
    //Get IP Address
    NSArray *addresses = [[NSHost currentHost] addresses];
    NSMutableString *temp = [[NSMutableString alloc] init];     //Hold IP addresses
    
    @try
    {
        for (NSString *anAddress in addresses)
        {
            //Check against home IP, is IP and temp doesn't already contain anAddress
            if (![anAddress hasPrefix:@"127"] && [[anAddress componentsSeparatedByString:@"."] count] == 4 && [temp rangeOfString:anAddress].location == NSNotFound)
            {
                if(![statusMenu itemWithTitle:anAddress])
                {
                    [self createIPAddressMenuItem:anAddress];
                    [filteredIPAddresses addObject:addresses];
                }
                
                for (NSMenuItem *item in [statusMenu itemArray])
                {
                    if (![addresses containsObject:item.title] && [[item.title componentsSeparatedByString:@"."] count] == 4)
                    {
                        [self cleanupMenuItems:item.title];
                    }
                }
                
            }

        }

    }
    @catch (NSException *e)
    {
        //NSLog(@"Exception: %@", e);
    }
    
}


//Preferences Clicked, show pref window
- (IBAction)preferences:(NSMenuItem *)sender
{
    @try
    {
        [preferences_Window makeKeyAndOrderFront:self];
        [NSApp activateIgnoringOtherApps:YES];
    }
    @catch (NSException *exception)
    {
       // NSLog(@"%@",exception);
    }
    
}


//About Button in Preference Window
- (IBAction)btn_about:(NSButton *)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}


//Run at Startup Check Box
- (IBAction)chk_runatStartup:(NSButtonCell *)sender
{
    //Directories to copy files to ~/Library/LaunchAgents
    
    NSString *whoamiPlist = [[[NSBundle mainBundle]resourcePath ]stringByAppendingPathComponent:@"com.WhoAmI.plist"];
    NSString *userDir = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/LaunchAgents/com.WhoAmI.plist"];
    NSString *delPlist = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/LaunchAgents/com.WhoAmI.plist"];
  
    //Check if chk_box is on or not.
    NSError *copyError;
    
    //Copy com.WhoAmI.plist from bundle
    if([chk_runatstartup state] == NSOnState)
    {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:userDir] == NO)
            [fileManager copyItemAtPath:whoamiPlist toPath:userDir error:&copyError];
    }
    
    //Delete com.WhoAmI.plist from ~/Library/LaunchAgents
    else if ([chk_runatstartup state] == NSOffState)
    {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:delPlist] == YES)
            [fileManager removeItemAtPath:delPlist error:&copyError];
    }
    
}


//Checks chk_userNotifications state and returns BOOL value
-(BOOL)useNotifications
{
    userSettings = [NSUserDefaults standardUserDefaults];
    BOOL useNotificats = [userSettings boolForKey:@"useNotifications"];
    
    if (useNotificats == YES)
    {
        return YES;
    }
    else
        return NO;
}

//chk_userNotifications is checked
- (IBAction)chkBoxUserSettings:(NSButtonCell *)sender
{
    
    if ([chk_useNotifications state] == NSOnState)
    {
        [userSettings setBool:YES forKey:@"useNotifications"];
    }
    else
    {
        [userSettings setBool:NO forKey:@"useNotifications"];
    }
    
    [userSettings synchronize];
}


- (void) createIPAddressMenuItem:(NSString*)ip
{
    /*
     If itemwithtitle(ip) does not exist
     create new menu item
     set title
     set image
     insert into menuindex
     */
    
    if(![statusMenu itemWithTitle:ip])
    {
        NSMenuItem *newItem;
        newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:ip action:@selector(copyMenuItem:) keyEquivalent:@""];
        if([ip isEqualToString:[[NSHost currentHost] localizedName]])
        {
            NSImage *computer = [NSImage imageNamed:@"computer"];
            [computer setTemplate:YES];
            [newItem setImage:computer];
            [statusMenu insertItem:newItem atIndex:0];
        }
        else
        {
            NSImage *network = [NSImage imageNamed:@"network"];
            [network setTemplate:YES];
            [newItem setImage:network];
            [statusMenu insertItem:newItem atIndex:1];
            [self createUserNotification:YES value:ip];
        }
    }
}

//Remove old IP addresses from menuitem
- (void) cleanupMenuItems:(NSString*)ip
{
    [statusMenu removeItem:[statusMenu itemWithTitle:ip]];
    [self createUserNotification:NO value:ip];
}


//Dealloc Memory
- (void) dealloc
{
    //TODO:
}

//Copies computer name to clipboard
-(void)copyMenuItem:(id)sender
{
    NSMenuItem *menuItem = (NSMenuItem*) sender;
    NSString *menuString = menuItem.title;
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard setString:[NSString stringWithFormat:@"%@",menuString] forType:NSStringPboardType];
    //NSLog(@"%@",[NSString stringWithFormat:@"%@",menuString]);
}

//For debug purposes only
- (void) printallArrayItems
{
    for (NSString *item in filteredIPAddresses)
    {
        NSLog(@"%@%@", item, @" in array.");
    }
}

//User Notification Setup and Delivery
- (void) createUserNotification:(bool)add value: (NSString*)item
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    if(add == YES)
    {
        notification.title = @"New";
    }
    else
    {
        notification.title = @"Removed";
    }
    
    notification.informativeText = [NSString stringWithFormat:@"%@",item];
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

//Change images to template images so they are 10.10 Dark Mode Compatible
- (void) setMenuItemImagesToTemplates
{
    NSImage *newPrefImage = [NSImage imageNamed:@"preferences"];
    NSImage *newExitmage = [NSImage imageNamed:@"exit"];
    [newPrefImage setTemplate:YES];
    [newExitmage setTemplate:YES];
    [statusMenu itemWithTitle:@"Preferences"].image = newPrefImage;
    [statusMenu itemWithTitle:@"Exit"].image = newExitmage;
}
@end
