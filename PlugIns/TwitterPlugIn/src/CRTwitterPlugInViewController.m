//  Copyright 2009 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "CRTwitterPlugInViewController.h"
#import "CRTwitterPlugIn.h"
#import "CRTimelineViewController.h"
#import "CRNoAccountsViewController.h"

@interface UMETabBarController ()
- (void)layoutSubviews;
@end

@implementation CRTwitterPlugInViewController

- (id)init {
    return [self initWithNibName:@"CRTwitterView" bundle:[NSBundle bundleForClass:[self class]]];
}


- (id)initWithNibName:(NSString *)s bundle:(NSBundle *)b {
    if (self = [super initWithNibName:s bundle:b]) {
        
    }
    return self;
}


- (void)dealloc {
#ifdef FUDEBUG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.plugIn = nil;
    self.noAccountsViewController = nil;
    self.tabBarController = nil;
    self.homeViewController = nil;
    self.homeNavController = nil;
    self.mentionsViewController = nil;
    self.mentionsNavController = nil;
    [super dealloc];
}


- (void)awakeFromNib {    
    if ([[[CRTwitterPlugIn instance] usernames] count]) {
        [self setUpTimelineAndMentions];
    } else{
        self.noAccountsViewController = [[[CRNoAccountsViewController alloc] init] autorelease];

        NSView *view = noAccountsViewController.view;
        [view setFrame:[[self view] bounds]];
        
        [noAccountsViewController viewWillAppear:NO];
        [[self view] addSubview:view];
        [noAccountsViewController viewDidAppear:NO];
    }
}


- (void)setUpTimelineAndMentionsIfNecessary {
    if (!tabBarController && [[[CRTwitterPlugIn instance] usernames] count]) {

        if (noAccountsViewController) {
            [noAccountsViewController.view removeFromSuperview];
            self.noAccountsViewController = nil;        
        }
        
        [self setUpTimelineAndMentions];
    }
}


- (void)setUpTimelineAndMentions {
    // timeline
    self.homeViewController = [[[CRTimelineViewController alloc] initWithType:CRTimelineTypeHome] autorelease];
    self.homeNavController = [[[UMENavigationController alloc] initWithRootViewController:homeViewController] autorelease];
    homeNavController.tabBarItem = [[[UMETabBarItem alloc] initWithTabBarSystemItem:UMETabBarSystemItemRecents tag:0] autorelease];
    homeNavController.tabBarItem.title = NSLocalizedString(@"Home", @"");
    
    
    // mentions
    self.mentionsViewController = [[[CRTimelineViewController alloc] initWithType:CRTimelineTypeMentions] autorelease];
    self.mentionsNavController = [[[UMENavigationController alloc] initWithRootViewController:mentionsViewController] autorelease];
    mentionsNavController.tabBarItem = [[[UMETabBarItem alloc] initWithTabBarSystemItem:UMETabBarSystemItemMostViewed tag:0] autorelease];
    mentionsNavController.tabBarItem.title = NSLocalizedString(@"Mentions", @"");
    
    // tabbar
    self.tabBarController = [[[UMETabBarController alloc] init] autorelease];
    tabBarController.viewControllers = [NSArray arrayWithObjects:homeNavController, mentionsNavController, nil];
    
    NSView *view = tabBarController.view;
    [view setFrame:[[self view] bounds]];
    
    [tabBarController viewWillAppear:NO];
    [[self view] addSubview:view];
    [tabBarController viewDidAppear:NO];
}


- (void)willAppear {
    //    UMENavigationController *nc = (UMENavigationController *)tabBarController.selectedViewController;
    //    [nc.topViewController viewWillAppear:NO];
}


- (void)didAppear {
    [tabBarController layoutSubviews];
    //    UMENavigationController *nc = (UMENavigationController *)tabBarController.selectedViewController;
    //    [nc.topViewController viewDidAppear:NO];
}


- (void)willDisappear {
    //    [tabBarController viewWillDisappear:NO];
    UMENavigationController *nc = (UMENavigationController *)tabBarController.selectedViewController;
    [nc.topViewController viewWillDisappear:NO];
}


- (void)didDisappear {
    //    [tabBarController viewDidDisappear:NO];
    UMENavigationController *nc = (UMENavigationController *)tabBarController.selectedViewController;
    [nc.topViewController viewDidDisappear:NO];
}


#pragma mark -
#pragma mark NSWindowDelegate

- (void)windowDidBecomeKey:(NSNotification *)n {
    NSAssert(plugIn, @"");
    [self setUpTimelineAndMentionsIfNecessary];
    [plugIn setFrontViewController:self];
}


- (void)windowDidBecomeMain:(NSNotification *)n {
    NSAssert(plugIn, @"");
    [self setUpTimelineAndMentionsIfNecessary];
    [plugIn setFrontViewController:self];
}

@synthesize plugIn;
@synthesize noAccountsViewController;
@synthesize tabBarController;
@synthesize homeViewController;
@synthesize homeNavController;
@synthesize mentionsViewController;
@synthesize mentionsNavController;
@end
