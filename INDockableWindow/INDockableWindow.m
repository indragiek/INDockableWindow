//
//  INDockableWindow.m
//  Flamingo
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

#import "INDockableWindow.h"

NSString* const INDockableWindowFinishedMovingNotification = @"INDockableWindowFinishedMovingNotification";

@interface INDockableWindow ()
@property (nonatomic, assign, readwrite) INDockableWindowController *dockableWindowController;
@end

@implementation INDockableWindow {
	NSRect _lastWindowFrame;
	
}
#pragma mark - Event Handling

- (void)sendEvent:(NSEvent *)theEvent
{
	if (theEvent.type == NSLeftMouseDown) {
		_lastWindowFrame = self.frame;
	} else {
		// TODO: Check for a specific event type/subtype for when the mouse has been released
		// NSWindow's dragging runs its own event loop so it NSLeftMouseUp events are not sent
		// The event(s) that are sent when the mouse has been released are these:
		// NSEvent: type=Kitdefined loc=(0,622) time=12283.8 flags=0x100 win=0x101928e40 winNum=4075 ctxt=0x0 subtype=4
		if (!NSEqualRects(self.frame, _lastWindowFrame)) {
			// Call super -sendEvent *before* sending the notification and return early because the window may
			// be removed and deallocated as a result of this notification being received, and calling super
			// would result in EXC_BAD_ACCESS
			[super sendEvent:theEvent];
			[[NSNotificationCenter defaultCenter] postNotificationName:INDockableWindowFinishedMovingNotification object:self];
			return;
		}
		_lastWindowFrame = NSZeroRect;
	}
	[super sendEvent:theEvent];
}

@end
