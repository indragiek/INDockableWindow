//
//  INDockableViewController.m
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

#import "INDockableViewController.h"
#import "INDockablePrimaryWindow.h"

@interface INDockableViewController ()
@property (nonatomic, assign, readwrite) INDockableWindowController *dockableWindowController;
@end

@interface INDockableDetachControl (Private)
@property (nonatomic, assign, readwrite) INDockableViewController *viewController;
@end

@implementation INDockableViewController {
	NSString *_UUID;
}
@synthesize uniqueIdentifier = _uniqueIdentifier;

- (void)commonInitForINDockableViewController
{
	_detachControl = [[INDockableDetachControl alloc] initWithFrame:NSZeroRect];
	_detachControl.viewController = self;
	_UUID = [[NSUUID UUID] UUIDString];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self commonInitForINDockableViewController];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self commonInitForINDockableViewController];
	}
	return self;
}

#pragma mark - Public API

- (void)viewControllerDidDetach
{
	[self.detachControl setHidden:NO];
}

- (void)viewControllerDidAttach
{
	[self.detachControl setHidden:YES];
}

#pragma mark - Accessors

- (void)setView:(NSView *)view
{
	[super setView:view];
	view.identifier = self.uniqueIdentifier;
}

- (BOOL)isAttached
{
	return [self.window isKindOfClass:[INDockablePrimaryWindow class]];
}

- (NSWindow *)window
{
	return self.view.window;
}

- (void)setUniqueIdentifier:(NSString *)uniqueIdentifier
{
	if (_uniqueIdentifier != uniqueIdentifier) {
		_uniqueIdentifier = uniqueIdentifier;
		self.view.identifier = uniqueIdentifier;
	}
}

- (NSString *)uniqueIdentifier
{
	return _uniqueIdentifier ?: _UUID;
}
@end
