//
//  INDockableDetachControl.m
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INDockableDetachControl.h"

@interface INDockableDetachControl ()
@property (nonatomic, assign, readwrite) INDockableViewController *viewController;
@end

@implementation INDockableDetachControl

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	
}

@end
