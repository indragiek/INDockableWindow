//
//  INDockableViewController.m
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INDockableViewController.h"
#import "INDockablePrimaryWindow.h"

@interface INDockableViewController ()
@property (nonatomic, assign, readwrite) INDockableWindowController *dockableWindowController;
@end

@interface INDockableDetachControl (Private)
@property (nonatomic, assign, readwrite) INDockableViewController *viewController;
@end

@implementation INDockableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        _detachControl = [[INDockableDetachControl alloc] initWithFrame:NSZeroRect];
		_detachControl.viewController = self;
    }
    return self;
}

#pragma mark - Public API

- (void)viewControllerDidDetach
{
	[self.detachControl setHidden:NO];
}

- (void)viewControllerDidAttach
{
	[self.detachControl setHidden:YES];
}

#pragma mark - Accessors

- (BOOL)isAttached
{
	return [self.window isKindOfClass:[INDockablePrimaryWindow class]];
}

- (NSWindow *)window
{
	return self.view.window;
}

- (void)setIdentifer:(NSString *)identifer
{
	if (_identifer != identifer) {
		_identifer = identifer;
		self.view.identifier = identifer;
	}
}
@end
