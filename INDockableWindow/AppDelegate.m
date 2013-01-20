//
//  AppDelegate.m
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate {
	INDockableWindowController *_windowController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_windowController = [INDockableWindowController new];
	_windowController.primaryViewController = self.primaryViewController;
	[_windowController showWindow:nil];
	[_windowController addViewController:self.secondaryViewController attached:YES];
}


- (IBAction)attach:(id)sender
{
	[_windowController attachViewController:self.secondaryViewController];
}

- (IBAction)detach:(id)sender
{
	[_windowController detachViewController:self.secondaryViewController];
}
@end
