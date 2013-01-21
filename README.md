## INDockableWindow
### Dockable window controller for AppKit

#### Overview

`INDockableWindow` is a collection of classes that allows you to create a column based application UI, where each column can be "docked" to a primary window and also separated into its own window by dragging on a detach handle. This type of UI can be seen in [Tweetbot for Mac](http://tapbots.com/software/tweetbot/mac/), for example.

**NOTE: This control, while feature complete, is still in early development, and is to be considered beta quality code at best.**

#### Features

* **Simple API.** There's really only 2 or 3 classes you'll need to interact with.
* **Fully customizable.** Everything, including size constraints, split view appearance, and the windows themselves are customizable.
* **Built on [INAppStoreWindow](https://github.com/indragiek/INAppStoreWindow)**. Every window is a subclass of `INAppStoreWindow`, so customizing the title bar and traffic lights is trivial.
* **User draggable split dividers.** When the views are docked on the main window, the size of each view is resizable via user draggable split dividers. The views maintain this width when they're popped into separate windows.
* **Smooth transition.** The smoothness of the transition between a docked view and an undocked window was a major consideration for this project, and the transition between the two is as fluid as possible.

#### Adding it to your project

* Clone this repository
* Run `git submodule update --init --recursive` to download `INAppStoreWindow`
* Add the `INAppStoreWindow` and `INDockableWindow` source code files to your project

##### ARC

**`INDockableWindow` requires ARC**. If your project doesn't use ARC, add the `-fobjc-arc` compiler flag to all of the `INDockableWindow` source files.

##### Auto Layout

**`INDockableWindow` does not support auto layout**. The behaviour is undefined when using auto layout.


#### Example

The project includes a simple example application that demonstrates docking and undocking with a 2 column layout:

![Docked](http://i.imgur.com/RtQtA4i.png)
![Undocked](http://i.imgur.com/5xNlePB.png)

I hope to write a more advanced example project at some point.

#### Documentation

Full documentation is inside the Documentation folder. The headers are also fully documented.

#### Getting Started

* Create a new instance of `INDockableWindowController`
* Assign the primary view controller (the "core view" that will always be displayed) to `primaryViewController`.
* Add additional view controllers using `-addViewController:attached:`

#### Contribution

Contributions via pull requests are always very welcome. I would greatly appreciate any fixes to bugs that you encounter, or implementation of additional features.

#### Contact

Indragie Karunaratne
[@indragie](http://twitter.com/indragie)
[http://indragie.com](http://indragie.com)

#### License

`INDockableWindow` is licensed under MIT. See LICENSE.md for more information.