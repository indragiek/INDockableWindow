//
//  INDockableWindowController.m
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INDockableWindowController.h"

@implementation INDockableWindowController {
	NSMutableSet *_auxiliaryWindows;
	NSMutableSet *_viewControllers;
	NSMutableArray *_attachedViewControllers;
	NSMutableDictionary *_minimumWidths;
	NSMutableDictionary *_maximumWidths;
	NSMutableDictionary *_shouldAdjust;
}
@synthesize auxiliaryWindows = _auxiliaryWindows;
@synthesize viewControllers = _viewControllers;
@synthesize attachedViewControllers = _attachedViewControllers;

- (id)init
{
	INDockablePrimaryWindow *window = [[INDockablePrimaryWindow alloc] initWithContentRect:NSMakeRect(0.f, 0.f, 800.f, 600.f) styleMask:self.windowStyleMask backing:NSBackingStoreBuffered defer:NO];
	if ((self = [super initWithWindow:window])) {
		_auxiliaryWindows = [NSMutableSet set];
		_viewControllers = [NSMutableSet set];
		_attachedViewControllers = [NSMutableArray array];
		_minimumWidths = [NSMutableDictionary dictionary];
		_maximumWidths = [NSMutableDictionary dictionary];
		_shouldAdjust = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self configurePrimaryWindow];
	[self configureSplitView];
	[self configurePrimaryViewController];
	[self resetTitlebarHeights];
}

#pragma mark - Accessors

- (NSUInteger)windowStyleMask
{
	return _windowStyleMask ?: (NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask);
}

- (void)setConfigurePrimaryWindowBlock:(void (^)(INDockablePrimaryWindow *))configurePrimaryWindowBlock
{
	if (_configurePrimaryWindowBlock != configurePrimaryWindowBlock) {
		_configurePrimaryWindowBlock = [configurePrimaryWindowBlock copy];
		[self configurePrimaryWindow];
	}
}

- (void)setPrimaryViewController:(INDockableViewController *)primaryViewController
{
	if (_primaryViewController != primaryViewController) {
		_primaryViewController = primaryViewController;
		[self configurePrimaryViewController];
	}
}

- (void)setTitleBarHeight:(CGFloat)titleBarHeight
{
	if (_titleBarHeight != titleBarHeight) {
		_titleBarHeight = titleBarHeight;
		[self resetTitlebarHeights];
	}
}

#pragma mark - Public API

- (INDockableViewController *)attachedViewControllerAtIndex:(NSUInteger)index
{
	return [self.attachedViewControllers objectAtIndex:index];
}

- (INDockableViewController *)viewControllerWithIdentifier:(NSString *)identifier
{
	__block INDockableViewController *controller = nil;
	[self.viewControllers enumerateObjectsUsingBlock:^(INDockableViewController *viewController, BOOL *stop) {
		if ([viewController.identifer isEqualToString:identifier]) {
			controller = viewController;
			*stop = YES;
		}
	}];
	return controller;
}

- (void)setIndex:(NSUInteger)index forAttachedViewController:(INDockableViewController *)viewController
{
	NSUInteger oldIndex = [self.attachedViewControllers indexOfObject:viewController];
	if (oldIndex != NSNotFound) {
		[_attachedViewControllers removeObjectAtIndex:oldIndex];
		[_attachedViewControllers insertObject:viewController atIndex:index];
		[self layoutViewControllers];
	}
}

- (NSUInteger)indexOAttachedfViewController:(INDockableViewController *)viewController
{
	return [self.attachedViewControllers indexOfObject:viewController];
}

- (void)addViewController:(INDockableViewController *)viewController attached:(BOOL)attached
{
	[_viewControllers addObject:viewController];
	if (attached) {
		[self insertViewController:viewController atIndex:[self.attachedViewControllers count]];
	} else {
		
	}
}

- (void)insertViewController:(INDockableViewController *)viewController atIndex:(NSUInteger)index
{
	[_viewControllers addObject:viewController];
	[_attachedViewControllers insertObject:viewController atIndex:index];
	[self layoutViewControllers];
}

- (void)insertViewController:(INDockableViewController *)viewController positioned:(INDockableViewRelativePosition)position relativeTo:(INDockableViewController *)anotherViewController
{
	NSUInteger index = [self.attachedViewControllers indexOfObject:anotherViewController];
	if (index == NSNotFound) return;
	NSUInteger insertionIndex = NSNotFound;
	switch (position) {
		case INDockableViewLeft:
			insertionIndex = MAX(0, index - 1);
			break;
		case INDockableViewRight:
			insertionIndex = MIN([self.attachedViewControllers count], index + 1);
			break;
	}
	if (insertionIndex == NSNotFound) return;
	[self insertViewController:viewController atIndex:insertionIndex];
}

- (void)removeViewController:(INDockableViewController *)viewController
{
	[_viewControllers removeObject:viewController];
	[_attachedViewControllers removeObject:viewController];
	NSWindow *window = viewController.window;
	if ([window isKindOfClass:[INDockableAuxiliaryWindow class]]) {
		[window close];
		[_auxiliaryWindows removeObject:window];
	} else {
		[self layoutViewControllers];
	}
}

- (void)detachViewController:(INDockableViewController *)viewController
{
	
}

- (void)attachViewController:(INDockableViewController *)viewController
{
	[self removeViewController:viewController];
	[self addViewController:viewController attached:YES];
}

- (void)setMinimumWidth:(CGFloat)width forViewController:(INDockableViewController *)viewController
{
	_minimumWidths[viewController.identifer] = @(width);
	[self.splitView adjustSubviews];
}

- (void)setMaximumWidth:(CGFloat)width forViewController:(INDockableViewController *)viewController
{
	_maximumWidths[viewController.identifer] = @(width);
	[self.splitView adjustSubviews];
}

- (void)setShouldAdjustSize:(BOOL)shouldAdjust ofViewController:(INDockableViewController *)viewController
{
	_shouldAdjust[viewController.identifer] = @(shouldAdjust);
	[self.splitView adjustSubviews];
}

#pragma mark - NSSplitViewDelegate

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
	return [_shouldAdjust[subview.identifier] boolValue];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
	
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
	
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
	return NO;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
	return NO;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
	return NO;
}

#pragma mark - Private

- (void)configurePrimaryWindow
{
	if (self.configurePrimaryWindowBlock)
		self.configurePrimaryWindowBlock(self.primaryWindow);
}

- (void)configureSplitView
{
	INDockableSplitView *splitView = [[INDockableSplitView alloc] initWithFrame:[self.window.contentView bounds]];
	splitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	splitView.delegate = self;
	[self.window.contentView addSubview:splitView];
	_splitView = splitView;
}

- (void)configurePrimaryViewController
{
	[self insertViewController:self.primaryViewController atIndex:0];
}

- (void)resetTitlebarHeights
{
	self.primaryWindow.titleBarHeight = self.titleBarHeight;
	[self.auxiliaryWindows enumerateObjectsUsingBlock:^(INDockableAuxiliaryWindow *window, BOOL *stop) {
		window.titleBarHeight = self.titleBarHeight;
	}];
}

- (void)layoutViewControllers
{
	self.splitView.subviews = [NSArray array];
	__block CGFloat totalWidth = 0.f;
	[self.attachedViewControllers enumerateObjectsUsingBlock:^(INDockableViewController *viewController, NSUInteger idx, BOOL *stop) {
		[self.splitView addSubview:viewController.view];
		totalWidth += NSWidth(viewController.view.bounds);
	}];
	[self.splitView adjustSubviews];
	NSRect windowFrame = self.primaryWindow.frame;
	windowFrame.size.width = totalWidth;
	[self.primaryWindow setFrame:windowFrame display:YES animate:self.animatesFrameChange];
}
@end
