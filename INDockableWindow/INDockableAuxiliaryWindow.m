//
//  INDockableAuxiliaryWindow.m
//  INDockableWindow
//
// Copyright (c) 2013, Indragie Karunaratne. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
// to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "INDockableAuxiliaryWindow.h"
#import "INDockableViewController.h"
#import "NSView+INImagingAdditions.h"

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
