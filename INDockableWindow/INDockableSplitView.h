//
//  INDockableSplitView.h
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 NSSplitView subclass that adds some options for easy customization.
 */
@interface INDockableSplitView : NSSplitView
/**
 Width of the split view dividers. Default is 1px.
 */
@property (nonatomic, assign) CGFloat dividerThickness;

/**
 Color of the split view dividers.
 */
@property (nonatomic, strong) NSColor *dividerColor;

/**
 Drawing block to draw your own custom dividers.
 */
@property (nonatomic, copy) void(^dividerDrawingBlock)(NSRect rect);
@end
