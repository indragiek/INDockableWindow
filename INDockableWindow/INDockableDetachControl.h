//
//  INDockableDetachControl.h
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class INDockableViewController;
/**
 Control that can be dragged to trigger a detach of its parent view controller from the primary window.
 */
@interface INDockableDetachControl : NSView
/**
 The detach control image.
 */
@property (nonatomic, strong) NSImage *image;

/**
 The minimum drag distance to trigger a detach
 */
@property (nonatomic, assign) CGFloat minimumDragDistance;

/**
 Whether the control fades in on mouse hover
 */
@property (nonatomic, assign) BOOL fadeOnHover;

/**
 The view controller that owns this detach control
 */
@property (nonatomic, assign, readonly) INDockableViewController *viewController;
@end
