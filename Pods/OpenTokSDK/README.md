OpenTok iOS SDK
===============

This package contains what you need to get you started using the OpenTok iOS SDK.

The OpenTok iOS SDK lets you use OpenTok video sessions in apps you build for iPad, iPhone, and iPod touch devices.
This means you can use OpenTok video sessions that connect iOS users with each other and with web clients.
For information on OpenTok, see http://tokbox.com/.

Documentation of the SDK is available here: 

http://tokbox.com/opentok/v1/libraries/client/ios/index.html

The OpenTokHelloWorld project is simplest sample app. The OpenTokBasic sample uses more of the API. These sample apps are also at GitHub:

https://github.com/opentok/OpenTok-iOS-Hello-World<br>
https://github.com/opentok/OpenTok-iOS-Basic-Tutorial

Support is available at the OpenTok forums: http://www.tokbox.com/forums/

Release Notes
-------------

September 17, 2003 - Version 1.4.3

* Fixed a bug that caused clients running iOS 7 to crash.

May 16, 2013 - Version 1.4.2

* Fixed some issues with running OpenTok applications in the background.
* Added native support for armv7s architecture.
* Fixed a bug that was causing inconsistent UI when manipulating media track functions (e.g. publishVideo, subscribeToAudio, etc.)

April 9, 2013 - Version 1.4.1

* Corrected the name of `[OTPublisherDelegate publisher:didChangeCameraPosition:]` message. (See the notes for
April 5, 2013.)

April 5, 2013 - Version 1.4.0

* You can now specify the camera a publisher uses by setting the `[OTPublisher cameraPosition]` property. The OTPublisherDelegate sends
the `[OTPublisherDelegate publisherDidChange:cameraPosition:]` message in response to a camera change.
* Publishers and subscribers now continue to publish and subscribe to streams when running in the background.
* This release includes bug fixes to improve performance and stability.

August 3, 2012 - Version 1.2.0

* This release officially supports 3G and 4G in addition to wifi internet connections.
* Video quality in iOS is markedly improved in this release.
* This release officially supports image snapshot functionality.

June 5, 2012

* Added OTVideoView, which gives view hierarchy access to components of a viewable object.

April 23, 2012

* Fixed a bug where the aspect ratio for publishers was incorrect at certain orientations.
* Improved average connection time for subscribers. Delegates should receive the [OTSubscriberDelegate subscriberVideoDataReceived:] message a bit faster.

April 5, 2012

* [OTPublisher cameraPosition] -- The preferred camera position. When setting this property, if the change is possible, the publisher will use the camera
with the specified position. If the publisher has begun publishing, getting this property returns the current camera position; if the publisher has not yet
begun publishing, getting this property returns the preferred camera position. Valid values are defined in the AVCaptureDevicePosition enum.
  
Known issues
------------

* Some features available in the OpenTok SDK for other platforms (such as JavaScript) are not supported in the OpenTok iOS SDK. These unsupported features include peer-to-peer streaming and archiving.

* The OpenTok iOS SDK supports iOS 5 and later only.

* You cannot publish streams in the iOS Simulator. Build and deploy to a supported iOS device.

* Our graphics rendering pipeline causes this error to be logged when debugging: "CGContextDrawImage: invalid context 0x0." This should not affect the performance of your app. If you experience video quality issues, please let us know.

* iOS 6.1.3 seems to have some issues when the OpenTok library is running in the background. We are investigating this.

For other issues, check the RELEASE_NOTES.txt file in the libOpentok directory.

Developer and client requirements
---------------------------------

* The OpenTok iOS SDK requires XCode 4.2 or later. XCode 4.2 requires Mac OS 10.6.8 or later.

* You need to test OpenTok apps on an iOS device running iOS 5. The OpenTok iOS SDK supports iPhone 3GS
(subscribing only), iPhone 4 and higher, iPod touch 4th generation and higher, and all iPad versions. 

* To test OpenTok apps on an iOS device, you will need to register as an Apple iOS developer at
[http://developer.apple.com/programs/register/](http://developer.apple.com/programs/register/).

* Download the latest version of the
[OpenTok iOS SDK](https://github.com/opentok/opentok-iOS-sdk).

Setting up your development environment
---------------------------------------

Download the [OpenTokHelloWorld sample app](https://github.com/opentok/OpenTok-iOS-Hello-World) and the
[OpenTok iOS SDK](https://github.com/opentok/opentok-iOS-sdk). The OpenTokHelloWorld app publishes to a demo session, and subscribes to its own stream
(or any other stream in the session). Included in the sample app directory is the OpenTok iOS library and other files you will need to develop
your own apps:

* **Opentok.framework** -- Add this framework to your project. Note that to use the library you must also 
include the Opentok.bundle file and the headers included in in the Frameworks directory of the OpenTokHelloWorld
sample app.

* **Opentok.bundle** -- Add the Opentok.bundle file to your project. The Opentok.bundle file is located
in the Opentok.framework/Versions/A/Resources subdirectory of the OpenTok iOS SDK. 

* **Frameworks directory** -- The OpenTok iOS library uses linked frameworks and dynamic libraries provided by iOS.
We cannot pre-link them in the OpenTok framework, so your project must link them. Expand the "Frameworks" directory
of the sample application in XCode project browser. Drag and drop the contents of this directory into your own iOS project.

You can generate a new session ID at this URL:

https://dashboard.tokbox.com/projects

You can also create a web page that connects to the same session as the OpenTokHello sample app.

Using the sample apps
---------------------

* The [OpenTokHello](https://github.com/opentok/OpenTok-iOS-Hello-World) sample app shows the most basic functionality of the OpenTok iOS SDK: connecting to sessions, publishing streams,
and subscribing to streams.
* The [OpenTokBasic](https://github.com/opentok/opentok-iOS-Basic-Tutorial) sample app uses more of the OpenTok iOS SDK than the OpenTokHello sample app does.

Creating your own app using the OpenTok iOS SDK
-----------------------------------------------

Here are the basic steps in creating your own app:

1. In XCode, create a new project. The simplest application is a Single-View application.

2. Open the project navigator in Xcode.

3. Drag the Opentok.framework directory from the Mac OS Finder to the Frameworks directory for for your project in XCode.

4. Drag the Opentok.bundle file from the Mac OS Finder to root directory for your project in XCode.

	The Opentok.bundle file is located in the Opentok.framework/Versions/A/Resources subdirectory of the OpenTok iOS SDK.


5. The OpenTok framework requires a few other frameworks and libraries to be added to your project. The easiest way to add them is
to copy them from the OpenTokHello sample app.

	Open the OpenTokHello sample app in XCode. Drag all of the additional frameworks from the frameworks folder (in the project navigator)
	of the OpenTokHello project into the frameworks folder of your project.
	
	The additional frameworks and libraries include the following: AudioToolbox.framework, AVFoundation.framework, CFNetwork.framework,
	CoreAudio.framework, CoreMedia.framework, CoreTelephony.framework, CoreVideo.framework, libz.dylib, libstdc++.dylib, MobileCoreServices.framework,
	OpenGLES.framework, QuartzCore.framework, Security.framework, SystemConfiguration.framework.

6. When running in the background, the OpenTok SDK requires certain Info.pList settings to continue publishing and subscribing to
audio video streams. In XCode, open Info tab for your app's target and add a Required Background Modes entry (if it does not already
exist). Add the following to the list of required background modes:

	- App plays audio
	- App provides Voice over IP services

Next steps:

1. In the ViewController.h file, add the following line (after `import <UIKit/UIKit.h>`):

		#import <Opentok/Opentok.h>

2. Assuming that your ViewController will implement the OTSessionDelegate, OTPublisherDelegate, and OTSubscriberDelegate protocols,
edit the `@interface` declaration in the ViewController.h file to the following:

		@interface ViewController : UIViewController <OTSessionDelegate, OTSubscriberDelegate, OTPublisherDelegate>

3. You will need to implement the required method in each protocol that you add (OTSessionDelegate, OTSubscriberDelegate, OTPublisherDelegate).

4. Add code to initialize and connect to an OpenTok session. And add code to publish and subscribe to streams.
See the code in the OpenTokHello application.


Connect with TokBox and with other OpenTok developers
-----------------------------------------------------

Your comments and questions are welcome. Come join the conversation at the [OpenTok iOS SDK forum](http://www.tokbox.com/forums/ios).
