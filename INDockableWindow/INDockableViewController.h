//
//  INDockableViewController.h
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
#import "INDockableDetachControl.h"

@class INDockableWindowController;
@class INDockableWindow;

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
@property (nonatomic, assign, readonly) INDockableWindow *window;
/**
 The view to display in the title bar. This view will be resized to fit the title bar size.
 */
@property (nonatomic, strong) IBOutlet NSView *titleBarView;

/**
 The unique identifier for this view controller. Set to a generated UUID by default.
 
 If you decide to set this yourself, ensure that this value is unique from the
 identifiers of any other view controllers. If this rule is not followed, the
 behaviour is undefined. Setting this identifier will set the identifier of this
 view controller's view as well. 
 
 @warning Do not modify the identifier of the view after
 the view controller has been created.
 */
@property (nonatomic, copy) NSString *uniqueIdentifier;

/**
 The index of the view controller in it's parent window controller if attached.
 If the view controller is detached, returns NSNotFound.
 */
@property (nonatomic, assign, readonly) NSUInteger index;

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
 Called when the view controller is about to become detached from the primary window
 
 Always call super somewhere in your implementation.
 */
- (void)viewControllerWillDetach;

/**
 Called when the view controller is detached from the primary window.
 
 Always call super somewhere in your implementation.
 */
- (void)viewControllerDidDetach;

/**
 Called when the view controller is about to attach to the primary window
 
 Always call super somewhere in your implementation.
 */
- (void)viewControllerWillAttach;

/**
 Called when the view controller is attached to the primary window
 
 Always call super somewhere in your implementation.
 */
- (void)viewControllerDidAttach;

/**
 Detach this view controller from the primary window.
 */
- (void)detach;

/**
 Attach this window to the primary window
 */
- (void)attach;
@end
