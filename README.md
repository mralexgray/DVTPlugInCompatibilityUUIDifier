
# `DVTPlugInCompatibilityUUIDifier`

![Sreneity Now](https://github.com/mralexgray/DVTPlugInCompatibilityUUIDifier/raw/master/Screenshots/alcatraz.art.png)

## _Permanent, automatic, and hassle-free_ `Xcode`/`Alcatraz` "compatibility" upgrades.

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

## Twitter

I'm [@mralexgray](http://twitter.com/mralexgray) on Twitter. Please [tweet](https://twitter.com/intent/tweet?button_hashtag=DVTPlugInCompatibilityUUIDifier&text=Permanent%2C+automatic%2C+and+hassle-free+Xcode%2FAlcatraz+upgrades.%20http%3A%2F%2Flinks.mrgray.com%2FMoPluginsMoProblems&via=mralexgray) about the plugin. 