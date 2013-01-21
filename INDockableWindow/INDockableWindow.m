//
//  INDockableWindow.m
//  Flamingo
//
//  Created by Indragie Karunaratne on 2013-01-21.
//  Copyright (c) 2013 nonatomic. All rights reserved.
//

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
			[[NSNotificationCenter defaultCenter] postNotificationName:INDockableWindowFinishedMovingNotification object:self];
		}
		_lastWindowFrame = NSZeroRect;
	}
	[super sendEvent:theEvent];
}

@end
