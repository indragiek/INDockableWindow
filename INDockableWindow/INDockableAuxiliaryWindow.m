//
//  INDockableAuxiliaryWindow.m
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

#import "INDockableAuxiliaryWindow.h"
#import "INDockableViewController.h"

@interface NSView (INAdditions)
@property (nonatomic, strong, readonly) NSImage *in_image;
@end

@implementation NSView (INAdditions)
- (NSImage *)in_image
{
	NSSize viewSize = [self bounds].size;
    NSBitmapImageRep *bir = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
    [bir setSize:viewSize];
    [self cacheDisplayInRect:[self bounds] toBitmapImageRep:bir];
    NSImage* image = [[NSImage alloc] initWithSize:viewSize];
    [image addRepresentation:bir];
    return image;
}
@end

@interface INDockableWindow (Private)
@property (nonatomic, assign, readwrite) INDockableWindowController *dockableWindowController;
@end

@implementation INDockableAuxiliaryWindow {
	NSImageView *_contentImageView;
	NSImageView *_titleBarImageView;
}

- (id)initWithViewController:(INDockableViewController *)viewController styleMask:(NSUInteger)styleMask;
{
	if ((self = [super initWithContentRect:viewController.view.bounds styleMask:styleMask backing:NSBackingStoreBuffered defer:NO])) {
		_viewController = viewController;
		self.dockableWindowController = viewController.dockableWindowController;
	}
	return self;
}

#pragma mark - Private

- (void)showViewControllerImage
{
	NSView *contentView = self.viewController.view;
	NSView *titleBarView = self.viewController.titleBarView;
	if (contentView) {
		_contentImageView = [[NSImageView alloc] initWithFrame:[self.contentView bounds]];
		_contentImageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		_contentImageView.image = contentView.in_image;
		[self.contentView addSubview:_contentImageView positioned:NSWindowBelow relativeTo:nil];
	}
	if (titleBarView) {
		_titleBarImageView = [[NSImageView alloc] initWithFrame:[self.titleBarView bounds]];
		_titleBarImageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		_titleBarImageView.image = titleBarView.in_image;
		[self.titleBarView addSubview:_titleBarImageView positioned:NSWindowBelow relativeTo:nil];
	}
	if (_viewController.view.superview == self.contentView) {
		[_viewController.view removeFromSuperview];
		[_viewController.titleBarView removeFromSuperview];
	}
}

- (void)showViewController
{
	NSView *view = _viewController.view;
	if (view) {
		view.frame = [self.contentView bounds];
		view.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
		[self.contentView addSubview:view positioned:NSWindowBelow relativeTo:nil];
	}
	
	NSView *titleBarView = _viewController.titleBarView;
	if (titleBarView) {
		titleBarView.frame = [self.titleBarView bounds];
		titleBarView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		[self.titleBarView addSubview:titleBarView positioned:NSWindowBelow relativeTo:nil];
	}
	
	[_contentImageView removeFromSuperview];
	[_titleBarImageView removeFromSuperview];
	_contentImageView = nil;
	_titleBarImageView = nil;
}
@end
