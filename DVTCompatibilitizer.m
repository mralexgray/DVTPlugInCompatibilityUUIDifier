
#import "DVTCompatibilitizer.h"

@import CoreServices;

#define			kXcodePluginSuffix	@".xcplugin"
#define  kPluginsDirectoryPath	@"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
#define  kCompatibilityUUIDKey	@"DVTPlugInCompatibilityUUID"
#define kCompatibilityUUIDsKey  kCompatibilityUUIDKey @"s"
#define    kInfoPlistComponent	@"Contents/Info.plist"
#define											FM	NSFileManager.defaultManager

@implementation DVTCompatibilitizer

+ (void) watchAndFixPluginsAsNeeded {

	[self notify:@"Xcode Plugin watchdog running!"];

  NSArray * pathsToWatch = [self.installedXcodes arrayByAddingObjectsFromArray:@[self.pluginsDirectoryPath]];

	CFAbsoluteTime latency = 10.;
  FSEventStreamContext *callbackInfo = NULL;
  FSEventStreamRef stream = FSEventStreamCreate(NULL, &_mycallback, callbackInfo,
                                               (__bridge CFArrayRef)pathsToWatch,
																									 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
																																				 latency,
																									 kFSEventStreamCreateFlagNone); /* Flags explained in reference */

   FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
   FSEventStreamStart(stream);
   CFRunLoopRun();
}

+ (void) fixPlugins {

  NSMutableArray *fixed = @[].mutableCopy;

  for (id x in self.installedPlugins) {

    id plpath = [[self.pluginsDirectoryPath stringByAppendingPathComponent:x] stringByAppendingPathComponent:kInfoPlistComponent];

    if (![FM fileExistsAtPath:plpath]) {

      NSLog(@"WARNING: Skipped %@, as it was missing.", plpath);
			continue;
		}

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithContentsOfFile:plpath];

		id a = d[kCompatibilityUUIDsKey];

    if (a && [a count] && [self _keysAreOK:a]) {

      NSLog(@"NOT fixing: %@... It's already ok!", x);
      continue;
    }

		a = a ? [a mutableCopy] : @[].mutableCopy;

    [a addObjectsFromArray:self.allCompatibilityUUIDs];

    d[kCompatibilityUUIDsKey] = [NSSet setWithArray:a].allObjects;

    BOOL ok = [d writeToFile:plpath atomically:YES];

    ok ? [fixed addObject:[x stringByDeletingPathExtension]] : nil;

    NSLog(@"%@: %@", ok ? @"FIXED" : @"FAILED TO FIX", x);
  }
  [self notify: fixed.count ? [fixed componentsJoinedByString:@" "] : @"All Plugins OK"];
}

#pragma mark - Static Info Fetchers

+ (NSArray*) installedPlugins { static NSArray * plugs;

  return plugs = plugs ?: ({
    NSError* error = nil;
    id x = [[FM contentsOfDirectoryAtPath:self.pluginsDirectoryPath error:&error] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
      return [evaluatedObject hasSuffix:kXcodePluginSuffix];
    }]];
    if (!x || error) NSLog(@"error getting plugin files at path %@: %@", self.pluginsDirectoryPath, error);
    x;
  });
}

+ (NSArray*) allCompatibilityUUIDs { static NSArray * uuids;

  return uuids = uuids ?: ({
    NSMutableArray *pot = @[].mutableCopy;
    for (id path in self.installedXcodes) {
      NSString *uuid = [self _cuuidsForXcode:path];
      if (uuid) [pot addObject:uuid];
    }
    [pot copy];
  });
}

+ (NSArray*) installedXcodes { static NSArray * xcodes;

  return xcodes = xcodes ?: ({
    CFArrayRef result = LSCopyApplicationURLsForBundleIdentifier(CFSTR("com.apple.dt.Xcode"), nil);
    !result ? nil : [(__bridge NSArray*) result valueForKeyPath:@"path"];
  });
}

+ (NSString*) pluginsDirectoryPath { static NSString * plugPath;

  return plugPath = plugPath ?: [NSURL fileURLWithPath:kPluginsDirectoryPath.stringByStandardizingPath.stringByResolvingSymlinksInPath.stringByExpandingTildeInPath isDirectory:YES].path;
}

#pragma mark - Utility

+ (void) notify:reason {  // Posts notifications on our behalf!

  id notifier = [[[NSBundle bundleForClass:self]
								pathForAuxiliaryExecutable:@"DVTCompatibilitizer.notfier.app"]
						stringByAppendingPathComponent:@"Contents/MacOS/applet"];

  system([[NSString stringWithFormat:@"title=\"%@\" message=\"%@\" \"%@\"", NSStringFromClass(self),
																																						reason ?: @"DVTCompatibilitized!",
																																						notifier] UTF8String]);
}

+ (BOOL) _keysAreOK: (NSArray*) testing {

  return ![self.allCompatibilityUUIDs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    return ![testing containsObject:evaluatedObject];
  }]].count && [NSSet setWithArray:testing].allObjects.count == testing.count;
}

+ (NSString*) _cuuidsForXcode:(NSString*)path {

  NSString *info = [path stringByAppendingPathComponent:kInfoPlistComponent];
  return [NSDictionary dictionaryWithContentsOfFile:info][kCompatibilityUUIDKey];
}

void _mycallback(
  ConstFSEventStreamRef            streamRef,
  void *                  clientCallBackInfo,
  size_t                           numEvents,
  void *                          eventPaths,
  const FSEventStreamEventFlags eventFlags[],
  const FSEventStreamEventId      eventIds[]) {

  NSLog(@"Fixing plugins due to some change!\n");
  BOOL needsFix = YES;
  for (int i = 0; i < numEvents; i++) {
    /* flags are unsigned long, IDs are uint64_t */
    NSLog(@"Change %llu in %s, flags %ui\n", eventIds[i], ((char**)eventPaths)[i], ((unsigned int)eventFlags[i]));
    if ([[NSString stringWithFormat:@"%s", ((char**)eventPaths)[i]] rangeOfString:@"DVTCompatibilitizer.notfier.app"].location != NSNotFound)
      needsFix = NO;
  }

  needsFix ? [DVTCompatibilitizer fixPlugins] : nil;
}

@end
