
@import Foundation;
@import CoreServices;

@interface DVTCompatibilitizer : NSObject

+  (NSArray*) installedPlugins;
+  (NSArray*) allCompatibilityUUIDs;
+  (NSArray*) installedXcodes;
+ (NSString*) pluginsDirectoryPath;
+      (void) fixPlugins;
+      (void) watchAndFixPluginsAsNeeded;

@end

#define kCompatibilityUUIDKey @"DVTPlugInCompatibilityUUID"
#define kCompatibilityUUIDsKey  kCompatibilityUUIDKey @"s"
#define kInfoPlistComponent @"Contents/Info.plist"
#define FM NSFileManager.defaultManager

#define kPluginsDirectoryPath @"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
#define kXcodePluginSuffix @".xcplugin"
