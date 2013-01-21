//
//  INDockableAuxiliaryWindow.m
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INDockableAuxiliaryWindow.h"
#import "INDockableViewController.h"

NSString* const INDockableAuxiliaryWindowFinishedMovingNotification = @"INDockablePrimaryWindowFinishedMovingNotification";

@interface NSView (INAdditions)
@property (nonatomic, strong, readonly) NSImage *in_image;
@end

@implementation NSView (INAdditions)
- (NSImage *)in_image
{
	NSSize viewSize = [self bounds].size;
    NSBitmapImageRep *bir = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
    [bir setSize:viewSize];
    [self cacheDisplayInRect:[self bounds] toBitmapImageRep:bir];
    NSImage* image = [[NSImage alloc] initWithSize:viewSize];
    [image addRepresentation:bir];
    return image;
}
@end

@implementation INDockableAuxiliaryWindow {
	NSImageView *_imageView;
	NSRect _lastWindowFrame;
}

- (id)initWithViewController:(INDockableViewController *)viewController styleMask:(NSUInteger)styleMask;
{
	if ((self = [super initWithContentRect:viewController.view.bounds styleMask:styleMask backing:NSBackingStoreBuffered defer:NO])) {
		_viewController = viewController;
		_dockableWindowController = viewController.dockableWindowController;
	}
	return self;
}

#pragma mark - Event Handling

- (void)sendEvent:(NSEvent *)theEvent
{
	if (theEvent.type == NSLeftMouseDown) {
		_lastWindowFrame = self.frame;
	} else {
		// TODO: Check for a specific event type/subtype for when the mouse has been released
		// NSWindow's dragging runs its own event loop so it NSLeftMouseUp events are not sent
		// The event(s) that are sent when the mouse has been released are these:
		// NSEvent: type=Kitdefined loc=(0,622) time=12283.8 flags=0x100 win=0x101928e40 winNum=4075 ctxt=0x0 subtype=4
		if (!NSEqualRects(self.frame, _lastWindowFrame)) {
			[[NSNotificationCenter defaultCenter] postNotificationName:INDockableAuxiliaryWindowFinishedMovingNotification object:self];
		}
		_lastWindowFrame = NSZeroRect;
	}
	[super sendEvent:theEvent];
}

#pragma mark - Private

- (void)showViewControllerImage
{
	_imageView = [[NSImageView alloc] initWithFrame:[self.contentView bounds]];
	_imageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	_imageView.image = self.viewController.view.in_image;
	[self.contentView addSubview:_imageView];
	if (_viewController.view.superview == self.contentView) {
		[_viewController.view removeFromSuperview];
		[_viewController.titleBarView removeFromSuperview];
	}
}

- (void)showViewController
{
	NSView *view = _viewController.view;
	if (view) {
		view.frame = [self.contentView bounds];
		view.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
		[self.contentView addSubview:view];
	}
	
	NSView *titleBarView = _viewController.titleBarView;
	if (titleBarView) {
		titleBarView.frame = [self.titleBarView bounds];
		titleBarView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		[self.titleBarView addSubview:titleBarView];
	}
	
	[_imageView removeFromSuperview];
	_imageView = nil;
}
@end
