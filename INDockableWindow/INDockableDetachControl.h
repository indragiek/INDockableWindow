//
//  INDockableDetachControl.h
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
