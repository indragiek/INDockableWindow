//
//  INDockableAuxiliaryWindow.m
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INDockableAuxiliaryWindow.h"
#import "INDockableViewController.h"

@implementation INDockableAuxiliaryWindow

- (id)initWithViewController:(INDockableViewController *)viewController styleMask:(NSUInteger)styleMask;
{
	if ((self = [super initWithContentRect:viewController.view.bounds styleMask:styleMask backing:NSBackingStoreBuffered defer:NO])) {
		_viewController = viewController;
		_dockableWindowController = viewController.dockableWindowController;
	}
	return self;
}
@end
