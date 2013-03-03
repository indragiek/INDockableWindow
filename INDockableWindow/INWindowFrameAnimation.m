//
//  INWindowFrameAnimation.m
//  Flamingo
//
//  Created by Indragie Karunaratne on 2013-03-02.
//  Copyright (c) 2013 nonatomic. All rights reserved.
//

#import "INWindowFrameAnimation.h"

@implementation INWindowFrameAnimation {
	NSRect _oldFrame;
}

#pragma mark - Initialization

- (id)initWithDuration:(NSTimeInterval)duration
		animationCurve:(NSAnimationCurve)animationCurve
				window:(NSWindow *)window
{
	if ((self = [super initWithDuration:duration animationCurve:animationCurve])) {
		_window = window;
		self.delegate = self;
		self.animationBlockingMode = NSAnimationNonblocking;
	}
	return self;
}

#pragma mark - Animation

- (void)startAnimationToFrame:(NSRect)frame
{
	_oldFrame = self.window.frame;
	_toFrame = frame;
	[self startAnimation];
}

#pragma mark - NSAnimation

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
	[super setCurrentProgress:progress];
	NSRect newWindowFrame = _oldFrame;
	newWindowFrame.origin.x += progress * (_toFrame.origin.x - _oldFrame.origin.x);
	newWindowFrame.origin.y += progress * (_toFrame.origin.y - _oldFrame.origin.y);
	newWindowFrame.size.width += progress * (_toFrame.size.width - _oldFrame.size.width);
	newWindowFrame.size.height += progress * (_toFrame.size.height - _oldFrame.size.height);
	[self.window setFrame:newWindowFrame display:YES];
}

#pragma mark - NSAnimationDelegate

- (void)animationDidEnd:(NSAnimation *)animation
{
	if (self.completionBlock) self.completionBlock(YES);
}

- (void)animationDidStop:(NSAnimation *)animation
{
	if (self.completionBlock) self.completionBlock(NO);
}
@end
