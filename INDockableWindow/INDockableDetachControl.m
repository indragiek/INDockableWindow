//
//  INDockableDetachControl.m
//  INDockableWindow
//
//  Copyright 2013 Indragie Karunaratne. All rights reserved.
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

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
