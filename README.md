
# `DVTPlugInCompatibilityUUIDifier`

![Sreneity Now](https://github.com/mralexgray/DVTPlugInCompatibilityUUIDifier/raw/master/Screenshots/alcatraz.art.png)

## _Permanent, automatic, and hassle-free_ `Xcode`/`Alcatraz` "`UUID compatibility`" "upgrades".

- [x] Are you *sick and tired* of thinking about / dealing with `Alcatraz` / all your `Xcode` plugins breaking with each `Xcode` release?

- [x] Have you tried those other hacks, and still you can't keep up with all the compatibility UUID's, aka `DVTPlugInCompatibilityUUIDs`?

- [x] Does the fact that `Alcatraz` doesn't do this automcatically make you want to _jump off a cliff_?

### Stop the insanity!!

Through the _magic of science_, the _ever-incompatible_ [`Alcatraz`](http://alcatraz.io) (and all it's little friends) will now "magically" BE compatible.  Wow.  Imagine.  If something doesn't work, don't cry!  *Just delete the offending plugin-in* from 

    ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/
		
and move on!  You can _always just install it later_ (now that you CAN depend on ALcatraz being available, via this plugin!)  

### Mo' Xcode's.. Mo' Problems..

--Xcode: PluginLoading: Required plug-in compatibility UUID XYZ-123-KILL-KILL-ALCATRAZ for plug-in at path '~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/SomeHaplessPlugin.xcplugin' not present in DVTPlugInCompatibilityUUIDs--


###**Serenity Now!**

- Automatically updates ALL your plugin's with ALL your installed Xcodes' various required UUID's, automatically!
- Make sure Alcatraz is ready to go when you update Xcode, without having to do ANYTHING!
- Works even when Xcode is closed, or if something changes with your plugins!
- Notifies you politely when it does something, or runs a check!

**Behold**

![Screenshot](https://github.com/mralexgray/DVTPlugInCompatibilityUUIDifier/raw/master/Screenshots/notification.png "Notifications!")

## Installation

Simply build this Xcode project once and restart Xcode. You can delete the project afterwards. (The plugin will be copied to your system automatically after the build.)

If you get a "Permission Denied" error while building, please see [this issue](https://github.com/omz/ColorSense-for-Xcode/issues/1) of the great [ColorSense plugin](https://github.com/omz/ColorSense-for-Xcode/).

The plugin automatically registers a LaunchAgent with `launchd`, which keeps 
 
    ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/DVTPlugInCompatibilityUUIDifier.xcplugin/Contents/MacOS/DVTPlugInCompatibilityWatchdog

 running for you, unassisted!  `DVTPlugInCompatibilityWatchdog` is the little macgic helper that makes sure you can ALWAYS be up and running with ALL your plugins/Alcatraz, no matter what!

![Screenshot](https://github.com/mralexgray/DVTPlugInCompatibilityUUIDifier/raw/master/Screenshots/xcode.hates.you.png "WAAAA. No cooties!")

**Make sure to always <kbd>Load Bundles</kbd> when prompted by _prissy/cooties-averse/xenophobic_ `Xcode`.**

## Uninstall

Either manually delete 

    ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/DVTPlugInCompatibilityUUIDifier.xcplugin

or use the great [JDPluginManager](https://github.com/jaydee3/JDPluginManager), and within `Xcode`, just go to <kbd>Plugins</kbd> `>` <kbd>DVTPlugInCompatibilityUUIDifier</kbd> `>` <kbd>Uninstall</kbd> 

and restart `Xcode`.

## Big picture / implementation details.
	
	DVTPlugInCompatibilityUUIDifier.xcplugin  
	└── Contents
	    ├── Info.plist
	    └── MacOS
	        ├── DVTPlugInCompatibilityUUIDifier  // The bundle's executable.
	        ├── DVTPlugInCompatibilityWatchdog   // The LaunchAgent that will always run.
	        └── DVTCompatibilitizer.notfier.app  // This bunlded app handles notifications
	            └── Contents
	                ├── Info.plist
	                ├── MacOS
	                │   └── applet
	                ├── PkgInfo
	                └── Resources
	                    ├── Scripts
	                    │   └── main.scpt
	                    ├── applet.icns
	                    ├── applet.rsrc
	                    └── description.rtfd
	                        └── TXT.rtf

First of all, this project requires [AHLaunchCTL](https://github.com/mralexgray/AHLaunchCTL).  However, if you forget to update/init your submodules, there is a pre-build step, 

    if [ ! -d AHLaunchCTL ]; then git submodule update --init --recursive; fi

that will handle it for you.

One problem the first version of this plug-in faced, was that when...

A. When Apple releases a new version of Xcode...
B. I have yet to upgrade this plugin's list of PlugIn CompatibilityUUID's...
C. Someone tries to install a NEW copy of this plugin...

that this plugin _never loads_, the watchdog _never runs_, and we are back to "square one".

> Existing users of this plug-in should be unafftected, as the watchdog is already running, theoretically, actively fixing all your plug-ins.
    
The solution is a bit hacky.. but again, inside of Xcode's build settings, I've added a "Post-Build" script...

![Hackity hack](https://github.com/mralexgray/DVTPlugInCompatibilityUUIDifier/raw/master/Screenshots/hacky.workaround.png)

which simply brute-force launches the included watchdog. This way.. EVEN if Xcode NEVER has loaded this plugin (due to it being fucking UUID incompatible)...  it won't matter.  Simply by being built successfully... the watchdog will be running.. and you will be protectced from the ravages of small inconvenience!

## Tests

Not only does the watchdog protect you from Alcatraz's refusal to self-update, and Apple's Nazi-esque "compatibility" police..  but it can ALSO test itself...  This isn't more than an internal mechanisms, but I might as well document it here, for my own benfit.


## Twitter

I'm [@mralexgray](http://twitter.com/mralexgray) on Twitter. Please [tweet](https://twitter.com/intent/tweet?button_hashtag=DVTPlugInCompatibilityUUIDifier&text=Permanent%2C+automatic%2C+and+hassle-free+Xcode%2FAlcatraz+upgrades.%20http%3A%2F%2Flinks.mrgray.com%2FMoPluginsMoProblems&via=mralexgray) about the plugin. 
