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

@implementation INDockableViewController {
	NSString *_UUID;
}
@synthesize uniqueIdentifier = _uniqueIdentifier;

- (void)commonInitForINDockableViewController
{
	_detachControl = [[INDockableDetachControl alloc] initWithFrame:NSZeroRect];
	_detachControl.viewController = self;
	_UUID = [[NSUUID UUID] UUIDString];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self commonInitForINDockableViewController];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self commonInitForINDockableViewController];
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

- (void)setView:(NSView *)view
{
	[super setView:view];
	view.identifier = self.uniqueIdentifier;
}

- (BOOL)isAttached
{
	return [self.window isKindOfClass:[INDockablePrimaryWindow class]];
}

- (NSWindow *)window
{
	return self.view.window;
}

- (void)setUniqueIdentifier:(NSString *)uniqueIdentifier
{
	if (_uniqueIdentifier != uniqueIdentifier) {
		_uniqueIdentifier = uniqueIdentifier;
		self.view.identifier = uniqueIdentifier;
	}
}

- (NSString *)uniqueIdentifier
{
	return _uniqueIdentifier ?: _UUID;
}
@end
