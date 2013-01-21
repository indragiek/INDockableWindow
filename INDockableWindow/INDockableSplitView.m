//
//  INDockableSplitView.m
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
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
