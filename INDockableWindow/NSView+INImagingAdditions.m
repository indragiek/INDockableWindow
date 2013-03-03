//
//  NSView+INImagingAdditions.m
//  Flamingo
//
//  Created by Indragie Karunaratne on 2013-03-02.
//  Copyright (c) 2013 nonatomic. All rights reserved.
//

#import "NSView+INImagingAdditions.h"

@implementation NSView (INImagingAdditions)
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
