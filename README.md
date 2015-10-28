
# `DVTPlugInCompatibilityUUIDifier`

![Sreneity Now](https://github.com/mralexgray/DVTPlugInCompatibilityUUIDifier/raw/master/Screenshots/alcatraz.art.png)

## _Permanent, automatic, and hassle-free_ Xcode upgrades.

- [x] Are you *sick and tired* of thinking about / dealing with Alcatraz / all your Xcode plugins breaking with each Xcode release?

- [x] Have you tried those other hacks, and still you can't keep up with all the compatibility UUID's?

- [x] Does the fact that Alcatraz doesn't do this automcatically make you want to jump off a cliff?

### Stop the insanity!!

Through the magic of science, the ever-incompatible [`Alcatraz`](http://alcatraz.io) (and all it's little friends) will now "magically" BE compatible.  Wow.  Imagine.  If something doesn't work, don't cry!  *Just delete the offending plugin-in* from ``~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/` and move on!  You can always just install it later (now that you can depend on ALcatraz being around!)  

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


## Uninstall

In Xcode, go to *Plugins > JDPluginManager > Uninstall* and restart Xcode afterwards.

## Twitter

I'm [@jaydee3](http://twitter.com/jaydee3) on Twitter. Please [tweet](https://twitter.com/intent/tweet?button_hashtag=JDPluginManager&text=This%20plugin%20manages%20Xcode%20plugins!%20Easy%20installing%20and%20uninstalling%20for%20plugins!%20https%3A%2F%2Fgithub.com%2Fjaydee3%2FJDPluginManager&via=jaydee3) about the plugin. 