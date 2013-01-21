//
//  INDockablePrimaryWindow.h
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INAppStoreWindow.h"

@class INDockableWindowController;
/** The primary window class */
@interface INDockablePrimaryWindow : INAppStoreWindow
/** 
 The dockable window controller that owns this window. 
 */
@property (nonatomic, assign, readonly) INDockableWindowController *dockableWindowController;
@end
