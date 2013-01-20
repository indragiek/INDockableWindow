//
//  INDockableSplitView.h
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface INDockableSplitView : NSSplitView
/**
 Width of the split view dividers.
 */
@property (nonatomic, assign) CGFloat dividerWidth;

/**
 Color of the split view dividers.
 @discussion This property has no effect if a `dividerDrawingBlock` has been set.
 */
@property (nonatomic, strong) NSColor *dividerColor;

/**
 Drawing block to draw your own custom dividers.
 @param rect The rect to draw the divider inside.
 */
@property (nonatomic, copy) void(^dividerDrawingBlock)(NSRect rect);
@end
