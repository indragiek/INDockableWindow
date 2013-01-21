//
//  INDockableViewController.h
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
#import "INDockableDetachControl.h"

@class INDockableWindowController;

/**
 View controller that displays the content for a single dockable pane of the dockable window controller.
 */
@interface INDockableViewController : NSViewController
/** 
 The dockable window controller that owns this view controller. 
 */
@property (nonatomic, assign, readonly) INDockableWindowController *dockableWindowController;
/** 
 The parent window of this view controller 
 */
@property (nonatomic, assign, readonly) NSWindow *window;
/**
 The view to display in the title bar. This view will be resized to fit the title bar size.
 */
@property (nonatomic, strong) IBOutlet NSView *titleBarView;

/**
 The unique identifier for this view controller. Set to a generated UUID by default.
 
 If you decide to set this yourself, ensure that this value is unique from the
 identifiers of any other view controllers. If this rule is not followed, the
 behaviour is undefined. Setting this identifier will set the identifier of this
 view controller's view as well. 
 
 @warning Do not modify the identifier of the view after
 the view controller has been created.
 */
@property (nonatomic, copy) NSString *uniqueIdentifier;

/**
 The detach control for the view controller. This control is automatically created when
 the view controller is created. It can be placed anywhere in your view hierarchy, and 
 dragging it will trigger a detach from the primary window.
 */
@property (nonatomic, strong, readonly) INDockableDetachControl *detachControl;

/**
 Whether this view controller is attached or in its own separate window.
 */
@property (nonatomic, assign, getter = isAttached) BOOL attached;

/**
 Called when the view controller is detached from the primary window.
 
 Always call super somewhere in your implementation.
 */
- (void)viewControllerDidDetach;

/**
 Called when the view controller is attached to the primary window
 
 Always call super somewhere in your implementation.
 */
- (void)viewControllerDidAttach;
@end
