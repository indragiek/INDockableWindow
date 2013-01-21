//
//  INDockableWindowController.m
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


#import "INDockableWindowController.h"

@interface INDockableViewController (Private)
@property (nonatomic, assign, readwrite) INDockableWindowController *dockableWindowController;
@end

@interface INDockableWindow (Private)
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
	NSMutableDictionary *_autosaveData;
}
@synthesize auxiliaryWindows = _auxiliaryWindows;
@synthesize viewControllers = _viewControllers;
@synthesize attachedViewControllers = _attachedViewControllers;
@synthesize titleBarHeight = _titleBarHeight;

- (id)init
{
	if ((self = [super initWithWindow:[[INDockablePrimaryWindow alloc] initWithContentRect:NSMakeRect(0.f, 0.f, 800.f, 600.f) styleMask:self.windowStyleMask backing:NSBackingStoreBuffered defer:NO]])) {
		_primaryWindow = (INDockablePrimaryWindow *)self.window;
		[_primaryWindow center];
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
		_maximumWindowHeight = FLT_MAX;
		_minimumWindowHeight = 0.f;
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(detachControlTriggeredDetach:) name:INDockableDetachControlTriggerNotification object:nil];
		[nc addObserver:self selector:@selector(primaryWindowDidMove:) name:NSWindowDidMoveNotification object:_primaryWindow];
		[nc addObserver:self selector:@selector(auxiliaryWindowFinishedMoving:) name:INDockableWindowFinishedMovingNotification object:_primaryWindow];
		[self configureSplitView];
		[self resetTitlebarHeights];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Accessors

- (NSUInteger)windowStyleMask
{
	return _windowStyleMask ?: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
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

- (void)setMinimumWindowHeight:(CGFloat)minimumWindowHeight
{
	if (_minimumWindowHeight != minimumWindowHeight) {
		_minimumWindowHeight = minimumWindowHeight;
		[self configureConstraintsForWindow:self.primaryWindow];
		[_auxiliaryWindows enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
			[self configureConstraintsForWindow:obj];
		}];
	}
}

- (void)setMaximumWindowHeight:(CGFloat)maximumWindowHeight
{
	if (_maximumWindowHeight != maximumWindowHeight) {
		_maximumWindowHeight = maximumWindowHeight;
		[self configureConstraintsForWindow:self.primaryWindow];
		[_auxiliaryWindows enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
			[self configureConstraintsForWindow:obj];
		}];
	}
}

- (void)setAutosaveName:(NSString *)autosaveName
{
	if (_autosaveName != autosaveName) {
		_autosaveData = [[[NSUserDefaults standardUserDefaults] objectForKey:autosaveName] mutableCopy];
		_autosaveName = autosaveName;
		[self.primaryWindow setFrameAutosaveName:autosaveName];
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
		if ([viewController.uniqueIdentifier isEqualToString:identifier]) {
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
		[self reorderPrimaryWindow];
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
	BOOL isAttached = [self.attachedViewControllers containsObject:viewController];
	if ([self.viewControllers containsObject:viewController] && !isAttached) {
		[self attachViewController:viewController];
	} else {
		[_viewControllers addObject:viewController];
		if (![self.attachedViewControllers containsObject:viewController]) {
			[_attachedViewControllers insertObject:viewController atIndex:index];
		}
		[self reorderPrimaryWindow];
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
	[viewController.titleBarView removeFromSuperview];
	viewController.dockableWindowController = nil;
	[_viewControllers removeObject:viewController];
	[_attachedViewControllers removeObject:viewController];
	if ([window isKindOfClass:[INDockableAuxiliaryWindow class]]) {
		[self removeAuxiliaryWindow:(INDockableAuxiliaryWindow *)window];
	}
	[self reorderPrimaryWindow];
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
		[self reorderPrimaryWindow];
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
		[self reorderPrimaryWindow];
	}];
	
	[self removeAuxiliaryWindow:window];
	if (_delegateFlags.viewControllerWasAttached) {
		[self.delegate dockableWindowController:self viewControllerWasAttached:viewController];
	}
}

- (void)setMinimumWidth:(CGFloat)width forViewController:(INDockableViewController *)viewController
{
	_minimumWidths[viewController.uniqueIdentifier] = @(width);
	if (viewController.attached) {
		[self.splitView adjustSubviews];
	} else {
		[self configureConstraintsForWindow:viewController.window];
	}
}

- (void)setMaximumWidth:(CGFloat)width forViewController:(INDockableViewController *)viewController
{
	_maximumWidths[viewController.uniqueIdentifier] = @(width);
	if (viewController.attached) {
		[self.splitView adjustSubviews];
	} else {
		[self configureConstraintsForWindow:viewController.window];
	}
}

- (void)setShouldAdjustSize:(BOOL)shouldAdjust ofViewController:(INDockableViewController *)viewController
{
	_shouldAdjust[viewController.uniqueIdentifier] = @(shouldAdjust);
	if (viewController.attached) {
		[self.splitView adjustSubviews];
	} else {
		[self configureConstraintsForWindow:viewController.window];
	}
}

#pragma mark - NSSplitViewDelegate

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
	NSNumber *shouldAdjust = _shouldAdjust[subview.identifier];
	if (shouldAdjust)
		return [shouldAdjust boolValue];
	return YES;
}

// Constraints code is based on BWSplitView <https://bitbucket.org/bwalkin/bwtoolkit/src/f164b18c9667/BWSplitView.m>

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
	CGFloat newMinFromThisSubview = proposedMin;
	CGFloat newMaxFromNextSubview = proposedMin;
	
	NSView *thisSubview = splitView.subviews[dividerIndex];
	NSNumber *min = _minimumWidths[thisSubview.identifier];
	if (min) {
		newMinFromThisSubview = NSMinX(thisSubview.frame) + min.doubleValue;
	}
	NSUInteger nextIndex = dividerIndex + 1;
	if ([splitView.subviews count] > nextIndex) {
		NSView *nextSubview = splitView.subviews[nextIndex];
		NSNumber *max = _maximumWidths[nextSubview.identifier];
		if (max) {
			newMaxFromNextSubview = NSMaxX(nextSubview.frame) - max.doubleValue - splitView.dividerThickness;
		}
	}
	CGFloat newMin = fmaxf(newMinFromThisSubview, newMaxFromNextSubview);
	if (newMin > proposedMin)
		return newMin;
	return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
	CGFloat newMaxFromThisSubview = proposedMax;
	CGFloat newMaxFromNextSubview = proposedMax;
	NSView *thisSubview = splitView.subviews[dividerIndex];
	NSNumber *max = _maximumWidths[thisSubview.identifier];
	if (max) {
		newMaxFromThisSubview = NSMinX(thisSubview.frame) + max.doubleValue;
	}
	NSUInteger nextIndex = dividerIndex + 1;
	if ([splitView.subviews count] > nextIndex) {
		NSView *nextSubview = splitView.subviews[nextIndex];
		NSNumber *min = _minimumWidths[nextSubview.identifier];
		if (min) {
			newMaxFromNextSubview = NSMaxX(nextSubview.frame) - min.doubleValue - splitView.dividerThickness;
		}
	}
	CGFloat newMax = fminf(newMaxFromThisSubview, newMaxFromNextSubview);
	if (newMax < proposedMax)
		return newMax;
	return proposedMax;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return floorf(proposedPosition);
}

- (void)splitViewWillResizeSubviews:(NSNotification *)aNotification
{
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
	[self layoutTitleBarViews];
	[self saveViewControllerAutosaveData];
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
	[splitView adjustSubviews];
}

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
	return NSZeroRect;
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
	[self layoutTitleBarViews];
}

- (void)layoutViewControllers
{
	__block CGFloat totalWidth = 0.f;
	__block CGFloat minWidth = 0.f;
	CGFloat dividerThickness = self.splitView.dividerThickness;
	[self.attachedViewControllers enumerateObjectsUsingBlock:^(INDockableViewController *viewController, NSUInteger idx, BOOL *stop) {
		NSView *view = viewController.view;
		NSRect newFrame = view.frame;
		newFrame.size.height = NSHeight(self.splitView.frame);
		
		NSNumber *autosaveWidth = _autosaveData[viewController.uniqueIdentifier];
		if (autosaveWidth) {
			newFrame.size.width = autosaveWidth.doubleValue;
			[_autosaveData removeObjectForKey:viewController.uniqueIdentifier];
		}
		NSNumber *min = _minimumWidths[viewController.uniqueIdentifier];
		minWidth += min.doubleValue;
		
		view.frame = newFrame;
		if (view.superview != self.splitView)
			[self.splitView addSubview:view];
		totalWidth += NSWidth(view.frame) + dividerThickness;
	}];
	totalWidth -= dividerThickness;
	NSRect windowFrame = self.primaryWindow.frame;
	windowFrame.size.width = totalWidth;
	[self.primaryWindow setFrame:windowFrame display:YES animate:_tempDisableFrameAnimation ? NO : self.animatesFrameChange];
	
	NSSize minSize = self.primaryWindow.minSize;
	minSize.width = minWidth;
	self.primaryWindow.minSize = minSize;
	
	NSRect splitViewFrame = self.splitView.frame;
	splitViewFrame.size.width = totalWidth;
	splitViewFrame.origin.x = 0.f;
	self.splitView.frame = splitViewFrame;
	[self.splitView adjustSubviews];
}

- (void)layoutTitleBarViews
{
	__block CGFloat currentOrigin = 0.f;
	NSView *titleBarView = self.primaryWindow.titleBarView;
	CGFloat dividerThickness = self.splitView.dividerThickness;
	[self.attachedViewControllers enumerateObjectsUsingBlock:^(INDockableViewController *viewController, NSUInteger idx, BOOL *stop) {
		NSView *titleView = viewController.titleBarView;
		NSRect newFrame = titleView.frame;
		newFrame.size.width = NSWidth(viewController.view.frame) + dividerThickness;
		newFrame.origin.x = currentOrigin;
		currentOrigin = NSMaxX(newFrame);
		titleView.frame = newFrame;
		titleView.autoresizingMask = NSViewWidthSizable;
		if (titleView.superview != titleBarView) 
			[titleBarView addSubview:titleView];
	}];
}

- (void)saveViewControllerAutosaveData
{
	if (![self.autosaveName length]) return;
	NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:[_viewControllers count]];
	[_viewControllers enumerateObjectsUsingBlock:^(INDockableViewController *viewController, BOOL *stop) {
		data[viewController.uniqueIdentifier] = @(NSWidth(viewController.view.frame));
	}];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:self.autosaveName];
}

- (void)reorderPrimaryWindow
{
	[self reorderViewControllers];
	[self reorderTitleBarViews];
}

- (void)reorderViewControllers
{
	self.splitView.subviews = [NSArray array];
	[self layoutViewControllers];
}

- (void)reorderTitleBarViews
{
	self.primaryWindow.titleBarView.subviews = [NSArray array];
	[self layoutTitleBarViews];
}

- (INDockableAuxiliaryWindow *)auxiliaryWindowForViewController:(INDockableViewController *)viewController
{
	INDockableAuxiliaryWindow *window = [[INDockableAuxiliaryWindow alloc] initWithViewController:viewController styleMask:self.windowStyleMask];
	window.titleBarHeight = self.titleBarHeight;
	[self configureConstraintsForWindow:window];
	[window setReleasedWhenClosed:NO];
	if (self.configureAuxiliaryWindowBlock)
		self.configureAuxiliaryWindowBlock(window);
	[self addAuxiliaryWindow:window];
	return window;
}

- (void)configureConstraintsForWindow:(NSWindow *)window
{
	NSSize minSize = window.minSize;
	if ([window isKindOfClass:[INDockableAuxiliaryWindow class]]) {
		INDockableViewController *viewController = [(INDockableAuxiliaryWindow *)window viewController];
		NSNumber *minWidth = _minimumWidths[viewController.uniqueIdentifier];
		if (minWidth) {
			minSize.width = minWidth.doubleValue;
		}
	}
	minSize.height = self.minimumWindowHeight;
	window.minSize = minSize;
	NSSize maxSize = window.maxSize;
	maxSize.height = self.maximumWindowHeight;
	window.maxSize = maxSize;
}

- (void)addAuxiliaryWindow:(INDockableAuxiliaryWindow *)window
{
	[_auxiliaryWindows addObject:window];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(auxiliaryWindowWillClose:) name:NSWindowWillCloseNotification object:window];
	[nc addObserver:self selector:@selector(auxiliaryWindowDidMove:) name:NSWindowDidMoveNotification object:window];
	[nc addObserver:self selector:@selector(auxiliaryWindowFinishedMoving:) name:INDockableWindowFinishedMovingNotification object:window];
}

- (void)removeAuxiliaryWindow:(INDockableAuxiliaryWindow *)window
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:NSWindowWillCloseNotification object:window];
	[nc removeObserver:self name:NSWindowDidMoveNotification object:window];
	[nc removeObserver:self name:INDockableWindowFinishedMovingNotification object:window];
	if (_delegateFlags.auxiliaryWindowDidClose) {
		[_delegate dockableWindowController:self auxiliaryWindowDidClose:window];
	}
	[_auxiliaryWindows removeObject:window];
	[window close];
}

#pragma mark - Notification

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

- (void)primaryWindowDidMove:(NSNotification *)notification
{
	CGFloat primaryMaxX = NSMaxX(self.primaryWindow.frame);
	__block INDockableAuxiliaryWindow *closestWindow = nil;
	__block CGFloat closestProximity = FLT_MAX;
	[self.auxiliaryWindows enumerateObjectsUsingBlock:^(INDockableAuxiliaryWindow *window, BOOL *stop) {
		CGFloat auxiliaryMinX = NSMinX(window.frame);
		CGFloat dx = fabs(auxiliaryMinX - primaryMaxX);
		if (dx < closestProximity) {
			closestProximity = dx;
			closestWindow = window;
			if (dx <= self.attachmentProximity) {
				NSRect newWindowFrame = self.primaryWindow.frame;
				newWindowFrame.origin.x = auxiliaryMinX - NSWidth(newWindowFrame);
				[self.primaryWindow setFrame:newWindowFrame display:YES];
				_shouldAttachAuxiliaryWindowOnMouseUp = YES;
			} else {
				_shouldAttachAuxiliaryWindowOnMouseUp = NO;
			}
			_lastMovedAuxiliaryWindow = window;
		}
	}];
}

- (void)performBlockWithoutAnimation:(void(^)())block
{
	_tempDisableFrameAnimation = YES;
	if (block) block();
	_tempDisableFrameAnimation = NO;
}

- (void)detachControlTriggeredDetach:(NSNotification *)notification
{
	[self detachViewController:notification.object];
}
@end
