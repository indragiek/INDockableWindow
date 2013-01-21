//
//  INDockableDetachControl.m
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


#import "INDockableDetachControl.h"
#import "INDockableViewController.h"

NSString* const INDockableDetachControlTriggerNotification = @"INDockableDetachControlTriggerNotification";

@interface INDockableDetachControl ()
@property (nonatomic, assign, readwrite) INDockableViewController *viewController;
@end

@implementation INDockableDetachControl {
	NSImageView *_imageView;
	NSTrackingArea *_trackingArea;
	NSPoint _initialPoint;
	BOOL _trackingTriggerAction;
}

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		_imageView = [[NSImageView alloc] initWithFrame:self.bounds];
		_imageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		[self addSubview:_imageView];
		_minimumDragDistance = 10.f;
    }
    return self;
}

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	if (_trackingArea) {
		[self removeTrackingArea:_trackingArea];
	}
	if (self.fadeOnHover) {
		_trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingActiveInKeyWindow | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
		[self addTrackingArea:_trackingArea];
	}
}

- (void)viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	[self updateTrackingAreas];
}

#pragma mark - Mouse Events

- (void)mouseEntered:(NSEvent *)theEvent
{
	[super mouseEntered:theEvent];
	[_imageView.animator setAlphaValue:1.f];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[super mouseExited:theEvent];
	[_imageView.animator setAlphaValue:0.f];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[super mouseDragged:theEvent];
	_initialPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	_trackingTriggerAction = YES;
}

CGFloat INDistanceBetweenPoints(NSPoint a, NSPoint b)
{
    CGFloat dx = a.x - b.x;
    CGFloat dy = a.y - b.y;
    return sqrt((dx * dx) + (dy * dy));
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if (_trackingTriggerAction) {
		if (INDistanceBetweenPoints(_initialPoint, point) >= self.minimumDragDistance) {
			[[NSNotificationCenter defaultCenter] postNotificationName:INDockableDetachControlTriggerNotification object:self.viewController userInfo:nil];
			_trackingTriggerAction = NO;
			// At this point, the events in the event loop are still using the coordinates of the primary window
			// even though the window has changed. Therefore, events need to be synthesized to convert the events
			// into new events with the proper coordinates for the new window.
			[self moveParentWindowWithEvent:[self.class synthesisedEventWithEvent:theEvent forWindow:self.window]];
		}
	} else {
		[self moveParentWindowWithEvent:theEvent];
	}
}

- (void)moveParentWindowWithEvent:(NSEvent *)theEvent
{
	NSPoint where = [self.window convertBaseToScreen:[theEvent locationInWindow]];
	NSPoint origin = [self.window frame].origin;
	while ((theEvent = [NSApp nextEventMatchingMask:NSLeftMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES]) && ([theEvent type] != NSLeftMouseUp)) {
		@autoreleasepool {
			if (theEvent.window != self.window) {
				theEvent = [self.class synthesisedEventWithEvent:theEvent forWindow:self.window];
			}
			NSPoint now = [self.window convertBaseToScreen:[theEvent locationInWindow]];
			origin.x += now.x - where.x;
			origin.y += now.y - where.y;
			[self.window setFrameOrigin:origin];
			where = now;
		}
	}
}

+ (NSEvent *)synthesisedEventWithEvent:(NSEvent *)theEvent forWindow:(NSWindow *)window
{
	NSPoint screenPoint = [theEvent.window convertBaseToScreen:[theEvent locationInWindow]];
	NSPoint windowPoint = [window convertScreenToBase:screenPoint];
	return [NSEvent mouseEventWithType:theEvent.type location:windowPoint modifierFlags:theEvent.modifierFlags timestamp:theEvent.timestamp windowNumber:window.windowNumber context:theEvent.context eventNumber:theEvent.eventNumber clickCount:theEvent.clickCount pressure:theEvent.pressure];
}

#pragma mark - Accessors

- (void)setImage:(NSImage *)image
{
	_imageView.image = image;
}

- (NSImage *)image
{
	return _imageView.image;
}

- (void)setFadeOnHover:(BOOL)fadeOnHover
{
	if (_fadeOnHover != fadeOnHover) {
		_fadeOnHover = fadeOnHover;
		_imageView.alphaValue = fadeOnHover ? 0.f : 1.f;
		[self updateTrackingAreas];
	}
}
@end
