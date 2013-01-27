//
//  INDockableWindowController.h
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


#import <Cocoa/Cocoa.h>
#import "INDockableViewController.h"
#import "INDockablePrimaryWindow.h"
#import "INDockableAuxiliaryWindow.h"
#import "INDockableSplitView.h"

@protocol INDockableWindowControllerDelegate;
/**
 Window controller that manages a collection of dockable views and auxiliary windows
 */
@interface INDockableWindowController : NSWindowController <NSSplitViewDelegate>
/**
 The window controller's delegate.
 */
@property (nonatomic, assign) id<INDockableWindowControllerDelegate> delegate;

/**
 The primary window that the auxiliary windows dock to.
 
 @warning The `titleBarHeight` of the window should not be set directly,
and should be set via the `titleBarHeight` property of the INDockableWindowController
 */
@property (nonatomic, strong, readonly) INDockablePrimaryWindow *primaryWindow;

/**
 Style mask to use when creating the primary and auxiliary windows.
 */
@property (nonatomic, assign) NSUInteger windowStyleMask;

/**
 Array of INDockableAuxiliaryWindow's that are detached from the primary window
 
 Windows in this array should not be modified. Set the `configureAuxiliaryWindowBlock` block to
 implement custom configuration for auxiliary windows.
 */
@property (nonatomic, strong, readonly) NSSet *auxiliaryWindows;

/**
 Block that is called to configure a new auxiliary window
 */
@property (nonatomic, copy) void(^configureAuxiliaryWindowBlock)(INDockableAuxiliaryWindow *window);

/**
 Array of INDockabieViewController's (both attached and detached from the primary window)
 */
@property (nonatomic, strong, readonly) NSSet *viewControllers;

/**
 Array of INDockableViewController's that are attached to the primary window
 
 The order of this array indicates the order in which the view controllers are displayed,
 from left to right.
 */
@property (nonatomic, strong, readonly) NSArray *attachedViewControllers;

/**
 The primary view controller that should always be visible. Auxiliary view controllers
 are added to the right of this primary view.
 */
@property (nonatomic, strong) INDockableViewController *primaryViewController;

/**
 The split view that displays each of the view controllers. You can use this reference to the split view
 to set divider width, color, and a custom divider drawing block.
 
 @warning Do not set the delegate of the split view. The delegate is
 automatically set to the INDockableWindowController. To override split view
 delegate methods, subclass the INDockableWindowController and override the split
 view delegate methods. INDockableWindowController implements all of the 
 methods documented in the NSSplitViewDelegate protocol. Always call super
 in any overriden implementations of delegate methods.
 */
@property (nonatomic, strong, readonly) INDockableSplitView *splitView;

/**
 The title bar height to use for all the windows (primary and auxiliary). Default is 22.f.
*/
@property (nonatomic, assign) CGFloat titleBarHeight;

/**
 The minimum height for the primary and auxiliary windows. Default is 0px.
 */
@property (nonatomic, assign) CGFloat minimumWindowHeight;

/**
 The maximum height for the primary and auxiliary windows. Default is FLT_MAX.
 
 Set to FLT_MAX to allow an unlimited window height.
 */
@property (nonatomic, assign) CGFloat maximumWindowHeight;

/**
 The minimum distance (in pixels) that a window needs to be dragged near the
 right edge of the primary window to attach it to the window. Default is 8px. 
 */
@property (nonatomic, assign) CGFloat attachmentProximity;

/**
 Autosave name for saving information to user defaults. 
 
 Setting an autosave name will enable the window controller to automatically
 save and restore the frames of view controllers and the primary window. The autossave data
 is keyed using the identifiers of the view controllers.
 */
@property (nonatomic, copy) NSString *autosaveName;

/**
 Set to YES to animate the addition and removal of view controllers by animating
 the frame change of the window. Default is NO.
 
 @warning This feature is experimental because NSWindow animation is terrible. Unexpected behaviour
 may result.
 */
@property (nonatomic, assign) BOOL animatesFrameChange;

/** @name Retrieving View Controllers */

/**
 Returns the attached view controller at the specified index.
 
 Throws an exception if `index` is not within the valid range of indices.
 @param index The index of the attached view controller (indicies are ordered from left to right).
 @return The attached view controller at the specified index.
 */
- (INDockableViewController *)attachedViewControllerAtIndex:(NSUInteger)index;

/**
 Returns the view controller with the specified identifier (attached or not).
 
 Returns nil if no view controller with the identifier is found.
 @param identifier The identifier of the view controller (set using the `identifier` property of INDockableViewController)
 @return The view controller with the specified identifier.
 */
- (INDockableViewController *)viewControllerWithIdentifier:(NSString *)identifier;

/** @name Positioning Attached View Controllers */

/**
 Moves an attached view controller to a new index.
 
 If `viewController` is not attached to the window, this method does nothing. If `index` is out of bounds, 
 an exception will be thrown
 @param index The index to move the view controller to.
 @param viewController The view controller to move.
 */
- (void)setIndex:(NSUInteger)index forAttachedViewController:(INDockableViewController *)viewController;

/**
 Returns the index of the specified attached view controller.
 @param viewController The attached view controller to get the index of.
 @return The index of the attached view controller, or NSNotFound if the view controller is nil or has not been attached
 */
- (NSUInteger)indexOAttachedfViewController:(INDockableViewController *)viewController;

/** @name Adding and Removing View Controllers */

/**
 Adds the specified view controller to the end of the view controller array.
 
 Does nothing if `viewController` has already been added.
 @param attached If YES, the view controller will be attached to the main window. If NO, the view controller
 will be placed inside an auxiliary window and the window will be shown.
 @param viewController The view controller to add
 */
- (void)addViewController:(INDockableViewController *)viewController attached:(BOOL)attached;

/**
 Adds the specified view controller to the window at the specified index.
 
 Throws an exception if `index` if out of bounds. If `viewController` is already attached to the window,
 this will just call -setIndex:forAttachedViewController: with the specified index.
 @param viewController The view controller to add and attach to the primary window
 @param index The index that the view controller will be placed at
 */
- (void)insertViewController:(INDockableViewController *)viewController atIndex:(NSUInteger)index;

/**
 Replaces the specified view controller with a new view controller
 
 This method only works for view controllers that are attached to the main window.
 @param oldViewController The view controller to remove
 @param newViewController The view controller to replace it with
 */
- (void)replaceAttachedViewController:(INDockableViewController *)oldViewController withViewController:(INDockableViewController *)newViewController;

/**
 Replaces the view controller at the specified index with a new view controller
 
 This method only works for view controllers that are attached to the main window.
 @param index The index of the view controller to replace
 @param viewController The view controller to replace it with
*/
- (void)replaceAttachedViewControllerAtIndex:(NSUInteger)index withViewController:(INDockableViewController *)viewController;

typedef NS_ENUM(NSInteger, INDockableViewRelativePosition) {
	INDockableViewRight,
	INDockableViewLeft
};

/**
 Adds the specified view controller to the window positioned relative to another attached view controller.
 
 This method does nothing if `viewController` is nil, `position` is not one of the defined values, or if `anotherViewController` is not attached to the primary window.
 @param viewController The view controller to add and attach to the primary window.
 @param position The relative position of the view controller
 @param anotherViewController The existing attached view controller to position the new view controller relative to
 */
- (void)insertViewController:(INDockableViewController *)viewController positioned:(INDockableViewRelativePosition)position relativeTo:(INDockableViewController *)anotherViewController;

/**
 Removes the specified view controller.
 
 If `viewController` is attached to the primary window, it will be removed from the window. If it is
 inside an auxiliary window, the window will be closed and removed.
 @param viewController The view controller to remove.
 */
- (void)removeViewController:(INDockableViewController *)viewController;

/** @name Attaching and Detaching View Controllers */

/** 
 Detaches the specified view controller from the primary window.
 
 If `viewController` is not attached to the primary window, this method does nothing.
 @param viewController The view controller to detach.
 */
- (void)detachViewController:(INDockableViewController *)viewController;

/**
 Attaches the specified view controller to the primary window.
 
 If `viewController` is already attached to the primary window, this method does nothing.
 @param viewController The view controller to attach
 */
- (void)attachViewController:(INDockableViewController *)viewController;

/** @name Managing Resizing of View Controllers */

/**
 Set a minimum width for the specified view controller.
 
 This method affects both the width of the view when its attached to the main window in the split view,
 and also affects the minimum size of any auxiliary window its in.
 @param width The minimum width.
 @param viewController The view controller to set the minimum width for.
 */
- (void)setMinimumWidth:(CGFloat)width forViewController:(INDockableViewController *)viewController;

/**
 Set a maximum width for the specified view controller.
 
 This method affects both the width of the view when its attached to the main window in the split view,
 and also affects the minimum size of any auxiliary window its in.
 @param width The maximum width.
 @param viewController The view controller to set the maximum width for.
 */
- (void)setMaximumWidth:(CGFloat)width forViewController:(INDockableViewController *)viewController;

/**
 Controls whether the view controller's view should be resized when the primary window is resized.
 
 This method only has any effect when the view controller is attached to the primary window. When detached
 in an auxiliary window, the view will always resize with the window unless maximum/minimum size constraints
 have been set on the auxiliary window (can be set in the `configureAuxiliaryWindowBlock` block).
 @param shouldAdjust YES if the view controller should resize with the primary window, NO otherwise.
 @param viewController The view controller.
 */
- (void)setShouldAdjustSize:(BOOL)shouldAdjust ofViewController:(INDockableViewController *)viewController;

/** @name Advanced Window Customization */

/**
 Subclasses can override this method to return an alternate class for the primary window.
 
 The window must be a subclass of INDockablePrimaryWindow.
 */
+ (Class)primaryWindowClass;

/**
 Subclasses can override this method to return an alternate class for the auxiliary window.
 
 The window must be a subclass of INDockableAuxiliaryWindow.
 */
+ (Class)auxiliaryWindowClass;
@end

/**
 The dockable window controller's delegate. Contains some methods that are useful for being notified 
 about events that were triggered by the user and not by methods called on the window controller
 */
@protocol INDockableWindowControllerDelegate <NSObject>
@optional
/**
 Called when a view controller is detached from the primary window.
 @param controller The dockable window controller.
 @param viewController The view controller that was detached.
 **/
- (void)dockableWindowController:(INDockableWindowController *)controller
	   viewControllerWasDetached:(INDockableViewController  *)viewController;

/** 
 Called when a view controller is attached to the primary window
 @param controller The dockable window controller.
 @param viewController The view controller that was attached.
 */
- (void)dockableWindowController:(INDockableWindowController *)controller
	   viewControllerWasAttached:(INDockableViewController *)viewController;

/**
 Called when the user closes an auxiliary window containing a dockable view controller.
 @param controller The dockable window controller.
 @param auxiliaryWindow The window that was closed.
 */
- (void)dockableWindowController:(INDockableWindowController *)controller
		 auxiliaryWindowDidClose:(INDockableAuxiliaryWindow *)auxiliaryWindow;

/**
 Called when a view controller (either attached or detached) is about to be removed.
 @param controller The dockable window controller.
 @param viewController The view controller that is about to be removed.
 */
- (void)dockableWindowController:(INDockableWindowController *)controller
		 willRemoveViewController:(INDockableViewController *)viewController;

/**
 Called when a view controller (either attached or detached) is removed
 @param controller The dockable window controller.
 @param viewController The view controller that was removed.
 */
- (void)dockableWindowController:(INDockableWindowController *)controller
		 didRemoveViewController:(INDockableViewController *)viewController;

/**
 Called when a view controller (either attached or detached) is about to be added
 @param controller The dockable window controller
 @param viewController The view controller that is about to be added
 */
- (void)dockableWindowController:(INDockableWindowController *)controller
			willAddViewController:(INDockableViewController *)viewController;

/**
 Called when a view controller (either attached or detached) is added
 @param controller The dockable window controller
 @param viewController The view controller that was added
 */
- (void)dockableWindowController:(INDockableWindowController *)controller
		 didAddViewController:(INDockableViewController *)viewController;

/** @name NSSplitViewDelegate Methods */

/** 
 The documentation for these methods can be found here: http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSSplitViewDelegate_Protocol/Reference/Reference.html
 */

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview;
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex;
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex;
- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex;
- (void)splitViewWillResizeSubviews:(NSNotification *)aNotification;
- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification;
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize;
- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex;

/**
 @warning It is recommended that you do not override the following NSSplitView
 delegate methods to allow collapsing. Using this class with collapsing enabled
 results in undefined behaviour
 */

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview;
- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex;
- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex;
@end
