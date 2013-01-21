//
//  INDockableSplitView.m
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

#import "INDockableSplitView.h"

@implementation INDockableSplitView {
	CGFloat in_dividerThickness;
	NSColor *in_dividerColor;
}

#pragma mark - NSSplitView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect])) {
		[self setVertical:YES];
		self.dividerStyle = NSSplitViewDividerStyleThin;
		in_dividerThickness = 1.f;
		in_dividerColor = [super dividerColor];
	}
	return self;
}

- (void)drawDividerInRect:(NSRect)rect
{
	NSRect integral = NSIntegralRect(rect);
	if (self.dividerDrawingBlock) {
		self.dividerDrawingBlock(integral);
	} else {
		[super drawDividerInRect:integral];
	}
}

#pragma mark - Accessors

- (void)setDividerThickness:(CGFloat)dividerThickness
{
	if (in_dividerThickness != dividerThickness) {
		in_dividerThickness = dividerThickness;
		[self adjustSubviews];
	}
}

- (CGFloat)dividerThickness
{
	return in_dividerThickness;
}

- (void)setDividerColor:(NSColor *)dividerColor
{
	if (in_dividerColor != dividerColor) {
		in_dividerColor = dividerColor;
		[self adjustSubviews];
	}
}

- (NSColor *)dividerColor
{
	return in_dividerColor;
}
@end
