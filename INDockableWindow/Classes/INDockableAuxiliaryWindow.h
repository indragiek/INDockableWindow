//
//  INDockableAuxiliaryWindow.h
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INAppStoreWindow.h"
/**
 This notification is posted when the user has finished moving the window and released the mouse
 */
extern NSString* const INDockableAuxiliaryWindowFinishedMovingNotification;

@class INDockableViewController, INDockableWindowController;
/** The auxiliary window class for displaying detached views */
@interface INDockableAuxiliaryWindow : INAppStoreWindow
/** 
 The dockabie view controller that this auxiliary window contains. 
 */
@property (nonatomic, strong, readonly) INDockableViewController *viewController;
/** 
 The dockable window controller that owns this window. 
 */
@property (nonatomic, assign) INDockableWindowController *dockableWindowController;
@end
