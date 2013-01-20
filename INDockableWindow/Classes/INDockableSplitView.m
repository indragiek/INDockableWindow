//
//  INDockableSplitView.m
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INDockableSplitView.h"

@implementation INDockableSplitView
//@synthesize dividerThickness = _dividerThickness;
//@synthesize dividerColor = _dividerColor;

#pragma mark - NSSplitView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect])) {
		[self setVertical:YES];
		self.dividerStyle = NSSplitViewDividerStyleThin;
		//_dividerThickness = 1.f;
		NSLog(@"FRAME");
	}
	return self;
}

/*- (void)drawDividerInRect:(NSRect)rect
{
	if (self.dividerDrawingBlock) {
		self.dividerDrawingBlock(rect);
	} else {
		[super drawDividerInRect:rect];
	}
}*/

#pragma mark - Accessors

/*- (void)setDividerThickness:(CGFloat)dividerThickness
{
	if (_dividerThickness != dividerThickness) {
		_dividerThickness = dividerThickness;
		[self adjustSubviews];
	}
}

- (CGFloat)dividerThickness
{
	return _dividerThickness;
}

- (void)setDividerColor:(NSColor *)dividerColor
{
	if (_dividerColor != dividerColor) {
		_dividerColor = dividerColor;
		[self adjustSubviews];
	}
}

- (NSColor *)dividerColor
{
	return [NSColor redColor];
	return _dividerColor ?: [super dividerColor];
}*/
@end
