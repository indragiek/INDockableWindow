//
//  INDockableWindowController.h
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INDockableViewController.h"
#import "INDockablePrimaryWindow.h"
#import "INDockableAuxiliaryWindow.h"
#import "INDockableSplitView.h"

@interface INDockableWindowController : NSWindowController <NSSplitViewDelegate>
/**
 The primary window that the auxiliary windows dock to.
 @discussion This window should not be modified directly. Set the `configurePrimaryWindowBlock` block to
 implement custom configuration for the primary window.
 */
@property (nonatomic, strong, readonly) INDockablePrimaryWindow *primaryWindow;
/**
 Array of INDockableAuxiliaryWindow's that are detached from the primary window
 @discussion Windows in this array should not be modified. Set the `configureAuxiliaryWindowBlock` block to 
 implement custom configuration for auxiliary windows.
 */
@property (nonatomic, strong, readonly) NSSet *auxiliaryWindows;

/**
 Block that is called to configure the `primaryWindow`
 @param window The primary window to configure.
 */
@property (nonatomic, copy) void(^configurePrimaryWindowBlock)(INDockablePrimaryWindow *window);

/**
 Block that is called to configure a new auxiliary window
 @param window The auxiliary window to configure.
 */
@property (nonatomic, copy) void(^configureAuxiliaryWindowBlock)(INDockableAuxiliaryWindow *window);

/**
 Array of INDockabieViewController's (both attached and detached from the primary window)
 */
@property (nonatomic, strong, readonly) NSSet *viewControllers;

/**
 Array of INDockableViewController's that are attached to the primary window
 @discussion The order of this array indicates the order in which the view controllers are displayed,
 from left to right.
 */
@property (nonatomic, strong, readonly) NSArray *attachedViewControllers;

/**
 The primary view controller that should always be visible. Auxiliary view controllers
 are added to the right of this primary view.
 */
@property (nonatomic, strong, readonly) INDockableViewController *primaryViewController;

/**
 The split view that displays each of the view controllers. You can use this reference to the split view
 to set divider width, color, and a custom divider drawing block.
 @discussion Do not set the delegate of the split view. The delegate is automatically set to the dockable view
 controller. To override split view delegate methods, subclass the dockable view controller and override the methods.
 */
@property (nonatomic, strong, readonly) INDockableSplitView *splitView;

/**
 The title bar height to use for all the windows (primary and auxiliary). Default is 22.f. The height of
 each titlebar can be overriden in `configurePrimaryWindowBlock` and `configureAuxiliaryWindowBlock`.
*/
@property (nonatomic, assign, readonly) CGFloat titleBarHeight;

/**
 Set to YES to animate the addition and removal of view controllers by animating the frame change of the window.
 Default is NO.
 */
@property (nonatomic, assign, readonly) BOOL animatesFrameChange;

/** @name Retrieving View Controllers */

/**
 Returns the attached view controller at the specified index.
 @param index The index of the attached view controller (indicies are ordered from left to right).
 @return The attached view controller at the specified index.
 @discussion Throws an exception if `index` is not within the valid range of indices.
 */
- (INDockableViewController *)attachedViewControllerAtIndex:(NSUInteger)index;

/**
 Returns the view controller with the specified identifier (attached or not).
 @param identifier The identifier of the view controller (set using the `identifier` property of INDockableViewController)
 @return The view controller with the specified identifier.
 @discussion Returns nil if no view controller with the identifier is found.
 */
- (INDockableViewController *)viewControllerWithIdentifier:(NSString *)identifier;

/** @name Positioning Attached View Controllers */

/**
 Moves an attached view controller to a new index.
 @param index The index to move the view controller to.
 @param viewController The view controller to move.
 @discussion If `viewController` is not attached to the window, this method does nothing. If 
 `index` is out of bounds, an exception will be thrown
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
 @param attached If YES, the view controller will be attached to the main window. If NO, the view controller
 will be placed inside an auxiliary window and the window will be shown.
 @param viewController The view controller to add
 @discussion Does nothing if `viewController` has already been added.
 */
- (void)addViewController:(INDockableViewController *)viewController attached:(BOOL)attached;

/**
 Adds the specified view controller to the window at the specified index.
 @param viewController The view controller to add and attach to the primary window
 @param index The index that the view controller will be placed at
 @discussion Throws an exception if `index` if out of bounds. If `viewController` is already attached to the window,
 this will just call -setIndex:forAttachedViewController: with the specified index.
 */
- (void)insertViewController:(INDockableViewController *)viewController atIndex:(NSUInteger)index;

typedef NS_ENUM(NSInteger, INDockableViewRelativePosition) {
	INDockableViewRight,
	INDockableViewLeft
};

/**
 Adds the specified view controller to the window positioned relative to another attached view controller.
 @param viewController The view controller to add and attach to the primary window.
 @param position The relative position of the view controller
 @param anotherViewController The existing attached view controller to position the new view controller relative to
 @discussion This method does nothing if `viewController` is nil, `position` is not one of the defined values, or if `anotherViewController` is not attached to the primary window.
 */
- (void)insertViewController:(INDockableViewController *)viewController positioned:(INDockableViewRelativePosition)position relativeTo:(INDockableViewController *)anotherViewController;

/**
 Removes the specified view controller.
 @param viewController The view controller to remove.
 @discussion If `viewController` is attached to the primary window, it will be removed from the window. If it is
 inside an auxiliary window, the window will be closed and removed.
 */
- (void)removeViewController:(INDockableViewController *)viewController;

/** @name Attaching and Detaching View Controllers */

/** 
 Detaches the specified view controller from the primary window.
 @param viewController The view controller to detach.
 @discussion If `viewController` is not attached to the primary window, this method does nothing.
 */
- (void)detachViewController:(INDockableViewController *)viewController;

/**
 Attaches the specified view controller to the primary window.
 @param viewController The view controller to attach
 @discussion If `viewController` is already deteched from the primary window, this method does nothing.
 */
- (void)attachViewController:(INDockableViewController *)viewController;

/** @name Managing Resizing of View Controllers */

/**
 Set a minimum width for the specified view controller.
 @param width The minimum width.
 @param viewController The view controller to set the minimum width for.
 @discussion This method only has any effect when the view controller is attached to the primary window.
 It does not restrict the size of the view controller's auxiliary window. Constraints for window sizes
 can be configured from the `configureAuxiliaryWindowBlock` block. When a view controller is attached
 to the primary window, it will be resized if necessary to fit the minimum width constraint.
 */
- (void)setMinimumWidth:(CGFloat)width forViewController:(INDockableViewController *)viewController;

/**
 Set a maximum width for the specified view controller.
 @param width The maximum width.
 @param viewController The view controller to set the maximum width for.
 @discussion This method only has any effect when the view controller is attached to the primary window.
 It does not restrict the size of the view controller's auxiliary window. Constraints for window sizes
 can be configured from the `configureAuxiliaryWindowBlock` block. When a view controller is attached
 to the primary window, it will be resized if necessary to fit the maximum width constraint.
 */
- (void)setMaximumWidth:(CGFloat)width forViewController:(INDockableViewController *)viewController;

/**
 Controls whether the view controller's view should be resized when the primary window is resized.
 @param shouldAdjust YES if the view controller should resize with the primary window, NO otherwise.
 @param viewController The view controller.
 @discussion This method only has any effect when the view controller is attached to the primary window. When detached
 in an auxiliary window, the view will always resize with the window unless maximum/minimum size constraints
 have been set on the auxiliary window (can be set in the `configureAuxiliaryWindowBlock` block).
 */
- (void)setShouldAdjustSize:(BOOL)shouldAdjust ofViewController:(INDockableViewController *)viewController;
@end

// These methods are useful for being notified of attach/detach events when views were attached and detached
// using the detach control vs. the methods on the window controller.
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
- (void)dockableWindowController:(INDockableViewController *)controller
		 auxiliaryWindowDidClose:(INDockableAuxiliaryWindow *)auxiliaryWindow;
@end