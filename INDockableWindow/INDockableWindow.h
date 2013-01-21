//
//  INDockableWindow.h
//  Flamingo
//
//  Created by Indragie Karunaratne on 2013-01-21.
//  Copyright (c) 2013 nonatomic. All rights reserved.
//

#import "INAppStoreWindow.h"

@class INDockableWindowController;
/**
 This notification is posted when the user has finished moving the window and released the mouse
 */
extern NSString* const INDockableWindowFinishedMovingNotification;

/**
 Base class for all windows used by INDockableWindowController
 */
@interface INDockableWindow : INAppStoreWindow
/**
 The dockable window controller that owns this window.
 */
@property (nonatomic, assign, readonly) INDockableWindowController *dockableWindowController;
@end
