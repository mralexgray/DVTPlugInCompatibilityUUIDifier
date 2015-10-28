//
//  main.m
//  DVTPlugInCompatibilityWatchdog
//
//  Created by Alex Gray on 10/27/15.
//
//

#import "DVTCompatibilitizer.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {
//      NSLog(@"%@", DVTCompatibilitizer.installedXcodes);
//      NSLog(@"%@", DVTCompatibilitizer.pluginsDirectoryPath);
//      NSLog(@"%@", [NSFileManager.defaultManager contentsOfDirectoryAtPath:DVTCompatibilitizer.pluginsDirectoryURL.path error:nil]);
//      NSLog(@"%@", DVTCompatibilitizer.installedPlugins);
//      [DVTCompatibilitizer fixPlugins];
      [DVTCompatibilitizer watchAndFixPluginsAsNeeded];
  }
    return 0;
}
