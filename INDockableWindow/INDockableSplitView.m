//
//  INDockableSplitView.m
//  INDockableWindow
//
//  Copyright 2013 Indragie Karunaratne. All rights reserved.
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
