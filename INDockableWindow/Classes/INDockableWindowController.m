//
//  INDockableWindowController.m
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INDockableWindowController.h"

@interface INDockableViewController (Private)
@property (nonatomic, assign, readwrite) INDockableWindowController *dockableWindowController;
@end

@interface INDockableAuxiliaryWindow (Private)
- (id)initWithViewController:(INDockableViewController *)viewController styleMask:(NSUInteger)styleMask;
- (void)showViewControllerImage;
- (void)showViewController;
@end

@implementation INDockableWindowController {
	NSMutableSet *_auxiliaryWindows;
	NSMutableSet *_viewControllers;
	NSMutableArray *_attachedViewControllers;
	NSMutableDictionary *_minimumWidths;
	NSMutableDictionary *_maximumWidths;
	NSMutableDictionary *_shouldAdjust;
	struct {
		unsigned int viewControllerWasDetached : 1;
		unsigned int viewControllerWasAttached : 1;
		unsigned int auxiliaryWindowDidClose : 1;
	} _delegateFlags;
	CGFloat _lastAuxiliaryWindowMinX;
	INDockableAuxiliaryWindow *_lastMovedAuxiliaryWindow;
	BOOL _shouldAttachAuxiliaryWindowOnMouseUp;
	BOOL _tempDisableFrameAnimation;
}
@synthesize auxiliaryWindows = _auxiliaryWindows;
@synthesize viewControllers = _viewControllers;
@synthesize attachedViewControllers = _attachedViewControllers;
@synthesize titleBarHeight = _titleBarHeight;

- (id)init
{
	if ((self = [super initWithWindow:[[INDockablePrimaryWindow alloc] initWithContentRect:NSMakeRect(0.f, 0.f, 800.f, 600.f) styleMask:self.windowStyleMask backing:NSBackingStoreBuffered defer:NO]])) {
		_primaryWindow = (INDockablePrimaryWindow *)self.window;
		[_primaryWindow setReleasedWhenClosed:NO];
		_auxiliaryWindows = [NSMutableSet set];
		_viewControllers = [NSMutableSet set];
		_attachedViewControllers = [NSMutableArray array];
		_minimumWidths = [NSMutableDictionary dictionary];
		_maximumWidths = [NSMutableDictionary dictionary];
		_shouldAdjust = [NSMutableDictionary dictionary];
		_attachmentProximity = 8.f;
		_titleBarHeight = 40.f;
		_animatesFrameChange = YES;
		[self configurePrimaryWindow];
		[self configureSplitView];
		[self resetTitlebarHeights];
	}
	return self;
}

#pragma mark - Accessors

- (NSUInteger)windowStyleMask
{
	return _windowStyleMask ?: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
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

- (void)setDelegate:(id<INDockableWindowControllerDelegate>)delegate
{
	if (_delegate != delegate) {
		_delegate = delegate;
		_delegateFlags.viewControllerWasAttached = [delegate respondsToSelector:@selector(dockableWindowController:viewControllerWasAttached:)];
		_delegateFlags.viewControllerWasDetached = [delegate respondsToSelector:@selector(dockableWindowController:viewControllerWasDetached:)];
		_delegateFlags.auxiliaryWindowDidClose = [delegate respondsToSelector:@selector(dockableWindowController:auxiliaryWindowDidClose:)];
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
		[self layoutPrimaryWindow];
	}
}

- (NSUInteger)indexOAttachedfViewController:(INDockableViewController *)viewController
{
	return [self.attachedViewControllers indexOfObject:viewController];
}

- (void)addViewController:(INDockableViewController *)viewController attached:(BOOL)attached
{
	if (attached) {
		[self insertViewController:viewController atIndex:[self.attachedViewControllers count]];
	} else {
		[_viewControllers addObject:viewController];
		INDockableAuxiliaryWindow *window = [self auxiliaryWindowForViewController:viewController];
		[window center];
		[window makeKeyAndOrderFront:nil];
	}
}

- (void)insertViewController:(INDockableViewController *)viewController atIndex:(NSUInteger)index
{
	viewController.dockableWindowController = self;
	BOOL isAttached = [_attachedViewControllers containsObject:viewController];
	if ([_viewControllers containsObject:viewController] && !isAttached) {
		[self attachViewController:viewController];
	} else {
		[_viewControllers addObject:viewController];
		if (![_attachedViewControllers containsObject:viewController]) {
			[_attachedViewControllers insertObject:viewController atIndex:index];
		}
		[self layoutPrimaryWindow];
	}
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
	if (viewController == self.primaryViewController) return;
	NSWindow *window = viewController.window;
	[viewController.view removeFromSuperview];
	viewController.dockableWindowController = nil;
	[_viewControllers removeObject:viewController];
	[_attachedViewControllers removeObject:viewController];
	if ([window isKindOfClass:[INDockableAuxiliaryWindow class]]) {
		[self removeAuxiliaryWindow:(INDockableAuxiliaryWindow *)window];
	}
	[self layoutPrimaryWindow];
}

- (void)detachViewController:(INDockableViewController *)viewController
{
	if (viewController == self.primaryViewController || viewController.window != self.primaryWindow) return;
	NSRect windowFrame = [viewController.view convertRect:viewController.view.bounds toView:nil];
	NSRect screenFrame = [self.primaryWindow convertRectToScreen:windowFrame];
	
	INDockableAuxiliaryWindow *window = [self auxiliaryWindowForViewController:viewController];
	screenFrame.size.height += window.titleBarHeight;
	[window setFrame:screenFrame display:YES];
	[window showViewControllerImage];
	[window makeKeyAndOrderFront:nil];
	
	[_attachedViewControllers removeObject:viewController];
	[self performBlockWithoutAnimation:^{
		[self layoutPrimaryWindow];
	}];
	[window showViewController];
	
	if (_delegateFlags.viewControllerWasDetached) {
		[self.delegate dockableWindowController:self viewControllerWasDetached:viewController];
	}
}

- (void)attachViewController:(INDockableViewController *)viewController
{
	if (viewController == self.primaryViewController || viewController.window == self.primaryWindow) return;
	INDockableAuxiliaryWindow *window = (INDockableAuxiliaryWindow *)viewController.window;
	[window showViewControllerImage];
	
	[_attachedViewControllers addObject:viewController];
	[self performBlockWithoutAnimation:^{
		[self layoutPrimaryWindow];
	}];
	
	[self removeAuxiliaryWindow:window];
	if (_delegateFlags.viewControllerWasAttached) {
		[self.delegate dockableWindowController:self viewControllerWasAttached:viewController];
	}
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
	return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
	return proposedMax;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return proposedPosition;
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

- (void)layoutPrimaryWindow
{
	[self layoutViewControllers];
	[self layoutTitleBar];
}

- (void)layoutViewControllers
{
	self.splitView.subviews = [NSArray array];
	__block CGFloat totalWidth = 0.f;
	[self.attachedViewControllers enumerateObjectsUsingBlock:^(INDockableViewController *viewController, NSUInteger idx, BOOL *stop) {
		NSView *view = viewController.view;
		NSRect newFrame = view.frame;
		newFrame.size.height = NSHeight(self.splitView.frame);
		view.frame = newFrame;
		[self.splitView addSubview:view];
		totalWidth += NSWidth(view.frame);
	}];
	NSRect windowFrame = self.primaryWindow.frame;
	windowFrame.size.width = totalWidth;
	[self.primaryWindow setFrame:windowFrame display:YES animate:_tempDisableFrameAnimation ? NO : self.animatesFrameChange];
	NSRect splitViewFrame = self.splitView.frame;
	splitViewFrame.size.width = totalWidth;
	splitViewFrame.origin.x = 0.f;
	self.splitView.frame = splitViewFrame;
	[self.splitView adjustSubviews];
}

- (void)layoutTitleBar
{
	self.primaryWindow.titleBarView.subviews = [NSArray array];
	__block CGFloat currentOrigin = 0.f;
	[self.attachedViewControllers enumerateObjectsUsingBlock:^(INDockableViewController *viewController, NSUInteger idx, BOOL *stop) {
		NSView *titleView = viewController.titleBarView;
		NSRect newFrame = titleView.frame;
		newFrame.size.width = NSWidth(viewController.view.frame) + self.splitView.dividerThickness;
		newFrame.origin.x = currentOrigin;
		currentOrigin = NSMaxX(newFrame);
		titleView.frame = newFrame;
		titleView.autoresizingMask = NSViewWidthSizable;
		[self.primaryWindow.titleBarView addSubview:titleView];
	}];
}

- (INDockableAuxiliaryWindow *)auxiliaryWindowForViewController:(INDockableViewController *)viewController
{
	INDockableAuxiliaryWindow *window = [[INDockableAuxiliaryWindow alloc] initWithViewController:viewController styleMask:self.windowStyleMask];
	window.titleBarHeight = self.titleBarHeight;
	[window setReleasedWhenClosed:NO];
	if (self.configureAuxiliaryWindowBlock)
		self.configureAuxiliaryWindowBlock(window);
	[self addAuxiliaryWindow:window];
	return window;
}

- (void)addAuxiliaryWindow:(INDockableAuxiliaryWindow *)window
{
	[_auxiliaryWindows addObject:window];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(auxiliaryWindowWillClose:) name:NSWindowWillCloseNotification object:window];
	[nc addObserver:self selector:@selector(auxiliaryWindowDidMove:) name:NSWindowDidMoveNotification object:window];
	[nc addObserver:self selector:@selector(auxiliaryWindowFinishedMoving:) name:INDockableAuxiliaryWindowFinishedMovingNotification object:window];
}

- (void)removeAuxiliaryWindow:(INDockableAuxiliaryWindow *)window
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:NSWindowWillCloseNotification object:window];
	[nc removeObserver:self name:NSWindowDidMoveNotification object:window];
	[nc removeObserver:self name:INDockableAuxiliaryWindowFinishedMovingNotification object:window];
	if (_delegateFlags.auxiliaryWindowDidClose) {
		[_delegate dockableWindowController:self auxiliaryWindowDidClose:window];
	}
	[_auxiliaryWindows removeObject:window];
	[window close];
}

- (void)auxiliaryWindowWillClose:(NSNotification *)notification
{
	[self removeViewController:[notification.object viewController]];
}

- (void)auxiliaryWindowDidMove:(NSNotification *)notification
{
	INDockableAuxiliaryWindow *window = notification.object;
	CGFloat primaryMaxX = NSMaxX(self.primaryWindow.frame);
	CGFloat auxiliaryMinX = NSMinX(window.frame);
	if (fabs(auxiliaryMinX - primaryMaxX) <= self.attachmentProximity) {
		NSRect newWindowFrame = window.frame;
		newWindowFrame.origin.x = primaryMaxX;
		[window setFrame:newWindowFrame display:YES];
		_shouldAttachAuxiliaryWindowOnMouseUp = YES;
	} else {
		_shouldAttachAuxiliaryWindowOnMouseUp = NO;
	}
	_lastMovedAuxiliaryWindow = window;
}

- (void)auxiliaryWindowFinishedMoving:(NSNotification *)notification
{
	if (_shouldAttachAuxiliaryWindowOnMouseUp) {
		[self attachViewController:_lastMovedAuxiliaryWindow.viewController];
		_shouldAttachAuxiliaryWindowOnMouseUp = NO;
		_lastMovedAuxiliaryWindow = nil;
	}
}

- (void)performBlockWithoutAnimation:(void(^)())block
{
	_tempDisableFrameAnimation = YES;
	if (block) block();
	_tempDisableFrameAnimation = NO;
}
@end
