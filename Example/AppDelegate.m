//
//  AppDelegate.m
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

#import "AppDelegate.h"

@implementation AppDelegate {
	INDockableWindowController *_windowController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_windowController = [INDockableWindowController new];
	_windowController.primaryViewController = self.primaryViewController;
	_windowController.splitView.dividerColor = [NSColor blackColor];
	[_windowController showWindow:nil];
	[_windowController addViewController:self.secondaryViewController attached:YES];
}

- (IBAction)attach:(id)sender
{
	[_windowController addViewController:self.secondaryViewController attached:YES];
}

- (IBAction)detach:(id)sender
{
	[_windowController detachViewController:self.secondaryViewController];
}
@end
