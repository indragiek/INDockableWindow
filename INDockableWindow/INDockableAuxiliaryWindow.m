//
//  INDockableAuxiliaryWindow.m
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INDockableAuxiliaryWindow.h"
#import "INDockableViewController.h"

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

@interface INDockableWindow (Private)
@property (nonatomic, assign, readwrite) INDockableWindowController *dockableWindowController;
@end

@implementation INDockableAuxiliaryWindow {
	NSImageView *_contentImageView;
	NSImageView *_titleBarImageView;
}

- (id)initWithViewController:(INDockableViewController *)viewController styleMask:(NSUInteger)styleMask;
{
	if ((self = [super initWithContentRect:viewController.view.bounds styleMask:styleMask backing:NSBackingStoreBuffered defer:NO])) {
		_viewController = viewController;
		self.dockableWindowController = viewController.dockableWindowController;
	}
	return self;
}

#pragma mark - Private

- (void)showViewControllerImage
{
	NSView *contentView = self.viewController.view;
	NSView *titleBarView = self.viewController.titleBarView;
	if (contentView) {
		_contentImageView = [[NSImageView alloc] initWithFrame:[self.contentView bounds]];
		_contentImageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		_contentImageView.image = contentView.in_image;
		[self.contentView addSubview:_contentImageView positioned:NSWindowBelow relativeTo:nil];
	}
	if (titleBarView) {
		_titleBarImageView = [[NSImageView alloc] initWithFrame:[self.titleBarView bounds]];
		_titleBarImageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		_titleBarImageView.image = titleBarView.in_image;
		[self.titleBarView addSubview:_titleBarImageView positioned:NSWindowBelow relativeTo:nil];
	}
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
		[self.contentView addSubview:view positioned:NSWindowBelow relativeTo:nil];
	}
	
	NSView *titleBarView = _viewController.titleBarView;
	if (titleBarView) {
		titleBarView.frame = [self.titleBarView bounds];
		titleBarView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		[self.titleBarView addSubview:titleBarView positioned:NSWindowBelow relativeTo:nil];
	}
	
	[_contentImageView removeFromSuperview];
	[_titleBarImageView removeFromSuperview];
	_contentImageView = nil;
	_titleBarImageView = nil;
}
@end
