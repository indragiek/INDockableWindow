//
//  INDockableDetachControl.h
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

extern NSString* const INDockableDetachControlTriggerNotification;

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
 The minimum drag distance to trigger a detach. Default is 10px.
 */
@property (nonatomic, assign) CGFloat minimumDragDistance;

/**
 Whether the control fades in on mouse hover. Default is NO.
 */
@property (nonatomic, assign) BOOL fadeOnHover;

/**
 The view controller that owns this detach control
 */
@property (nonatomic, assign, readonly) INDockableViewController *viewController;
@end
