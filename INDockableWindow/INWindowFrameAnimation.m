//
//  INWindowFrameAnimation.m
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
