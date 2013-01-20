//
//  AppDelegate.h
//  INDockableWindow
//
//  Created by Indragie Karunaratne on 2013-01-19.
//  Copyright (c) 2013 indragie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INDockableWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet INDockableViewController *primaryViewController;
@property (nonatomic, strong) IBOutlet INDockableViewController *secondaryViewController;

- (IBAction)attach:(id)sender;
- (IBAction)detach:(id)sender;
@end
