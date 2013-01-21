//
//  INDockableAuxiliaryWindow.h
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import "INDockableWindow.h"

@class INDockableViewController;
/** The auxiliary window class for displaying detached views */
@interface INDockableAuxiliaryWindow : INDockableWindow
/** 
 The dockabie view controller that this auxiliary window contains. 
 */
@property (nonatomic, strong, readonly) INDockableViewController *viewController;
@end
