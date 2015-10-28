# DVTPlugInCompatibilityUUIDifier

## Serenity now! _Perpetual, automatic, and hassle-free_ Xcode plugin compatibility.

Are you *sick and tired* of thinking about / dealing with compatibility UUID's every time you update Xcode?

Does reading this make you want to jump off a cliff?

`
Xcode: [MT] PluginLoading: Required plug-in compatibility UUID XYZ-123-KILL-KILL-ALCATRAZ for plug-in at path '~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/SomeHaplessPlugin.xcplugin' not present in DVTPlugInCompatibilityUUIDs
`

**Key Features:**

- Automatically updates ALL your plugin's with ALL your various Xcode's UUID's.
- Automatically updates Alcatraz when you update Xcode, without having to do ANYTHING!
- Works even when Xcode is closed!
- Notifies you when it does something!

**Screenshots:**

![Screenshot](assets/screenshot1.png "Menu Screenshot")
![Screenshot](assets/screenshot2.png "Uninstall Screenshot")
![Screenshot](assets/screenshot3.png "Installation Screenshot")

## Installation

Simply build this Xcode project once and restart Xcode. You can delete the project afterwards. (The plugin will be copied to your system automatically after the build.)

If you get a "Permission Denied" error while building, please see [this issue](https://github.com/omz/ColorSense-for-Xcode/issues/1) of the great [ColorSense plugin](https://github.com/omz/ColorSense-for-Xcode/).


## Uninstall

In Xcode, go to *Plugins > JDPluginManager > Uninstall* and restart Xcode afterwards.

## Twitter

I'm [@jaydee3](http://twitter.com/jaydee3) on Twitter. Please [tweet](https://twitter.com/intent/tweet?button_hashtag=JDPluginManager&text=This%20plugin%20manages%20Xcode%20plugins!%20Easy%20installing%20and%20uninstalling%20for%20plugins!%20https%3A%2F%2Fgithub.com%2Fjaydee3%2FJDPluginManager&via=jaydee3) about the plugin. 