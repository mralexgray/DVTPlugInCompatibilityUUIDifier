//
//  DVTCompatibilitizer.h
//  DVTPlugInCompatibilityUUIDifier
//
//  Created by Alex Gray on 10/27/15.
//
//

@import AppKit;

@interface DVTCompatibilitizer : NSObject

+  (NSArray*) installedPlugins;
+  (NSArray*) allCompatibilityUUIDs;
+  (NSArray*) installedXcodes;
+ (NSString*) pluginsDirectoryPath;
+      (void) fixPlugins;
+      (void) watchAndFixPluginsAsNeeded;

@end
