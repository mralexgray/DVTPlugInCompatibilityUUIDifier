
@import Foundation;

@interface DVTCompatibilitizer : NSObject

+  (NSArray*) installedPlugins;
+  (NSArray*) allCompatibilityUUIDs;
+  (NSArray*) installedXcodes;
+ (NSString*) pluginsDirectoryPath;
+      (void) fixPlugins;
+      (void) watchAndFixPluginsAsNeeded;

@end
