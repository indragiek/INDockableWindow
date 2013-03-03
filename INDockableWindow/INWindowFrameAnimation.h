//
//  INWindowFrameAnimation.h
//  Flamingo
//
//  Created by Indragie Karunaratne on 2013-03-02.
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

/**
 * NSAnimation subclass for animating the frame of a window
 * This is used instead of NSWindow's animation methods because they block the main thread
 * This animation performs the same task, except with variable animation durve and without
 * blocking the main thread.
 
 * Do not set the delegate of this object. Delegate methods are handled internally.
 */
@interface INWindowFrameAnimation : NSAnimation <NSAnimationDelegate>
@property (nonatomic, strong, readonly) NSWindow *window;
@property (nonatomic, assign) NSRect toFrame;
@property (nonatomic, copy) void (^completionBlock)(BOOL finished);

/**
 Creates a new INWindowFrameAnimation object.
 @param duration The animation duration
 @param animationCurve The animation timing function
 @param window The window to animate
 @return An instance of INWindowFrameAnimation
 */
- (id)initWithDuration:(NSTimeInterval)duration
		animationCurve:(NSAnimationCurve)animationCurve
				window:(NSWindow *)window;

/**
 Animates the winow to the specified frame.
 @param frame The frame to animate to
 */
- (void)startAnimationToFrame:(NSRect)frame;
@end
