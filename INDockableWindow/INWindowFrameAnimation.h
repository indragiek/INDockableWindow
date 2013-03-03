//
//  INWindowFrameAnimation.h
//  Flamingo
//
//  Created by Indragie Karunaratne on 2013-03-02.
//  Copyright (c) 2013 nonatomic. All rights reserved.
//

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
