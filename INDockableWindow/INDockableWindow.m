//
//  INDockableWindow.m
//  Flamingo
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
