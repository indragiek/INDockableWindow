//
//  INDockableViewController.h
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INDockableDetachControl.h"

@class INDockableWindowController;

/**
 View controller that displays the content for a single dockable pane of the dockable window controller.
 */
@interface INDockableViewController : NSViewController
/** 
 The dockable window controller that owns this view controller. 
 */
@property (nonatomic, assign, readonly) INDockableWindowController *dockableWindowController;
/** 
 The parent window of this view controller 
 */
@property (nonatomic, assign, readonly) NSWindow *window;
/**
 The view to display in the title bar. This view will be resized to fit the title bar size.
 */
@property (nonatomic, strong) NSView *titleBarView;

/**
 The unique identifier for this view controller. Set to a generated UUID by default.
 */
@property (nonatomic, copy) NSString *identifer;

/**
 The detach control for the view controller. This control is automatically created when
 the view controller is created. It can be placed anywhere in your view hierarchy, and 
 dragging it will trigger a detach from the primary window.
 */
@property (nonatomic, strong, readonly) INDockableDetachControl *detachControl;

/**
 Whether this view controller is attached or in its own separate window.
 */
@property (nonatomic, assign, getter = isAttached) BOOL attached;

/**
 Called when the view controller is detached from the primary window.
 
 Always call super somewhere in your implementation.
 */
- (void)viewControllerDidDetach;

/**
 Called when the view controller is attached to the primary window
 
 Always call super somewhere in your implementation.
 */
- (void)viewControllerDidAttach;
@end
