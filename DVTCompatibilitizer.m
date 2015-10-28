
@import CoreServices;

#import "DVTCompatibilitizer.h"

#define kCompatibilityUUIDKey @"DVTPlugInCompatibilityUUID"
#define kCompatibilityUUIDsKey  kCompatibilityUUIDKey @"s"
#define kInfoPlistComponent @"Contents/Info.plist"
#define FM NSFileManager.defaultManager

#define kPluginsDirectoryPath @"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
#define kXcodePluginSuffix @".xcplugin"

//#define  NSLog(...)  (void)fprintf(stderr,"%s\n",[NSString stringWithFormat:__VA_ARGS__,nil].UTF8String)

@implementation DVTCompatibilitizer

#pragma mark - Utility

static NSArray * xcodes = nil,
                * uuids = nil,
                * plugs = nil;
static NSString * plugPath = nil;


+ (BOOL) _keysAreOK: (NSArray*) testing {

  return ![self.allCompatibilityUUIDs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    return ![testing containsObject:evaluatedObject];
  }]].count && [NSSet setWithArray:testing].allObjects.count == testing.count;
}

+ (NSString*) _cuuidsForXcode:(NSString*)path {

  NSString *info = [path stringByAppendingPathComponent:kInfoPlistComponent];
  return [NSDictionary dictionaryWithContentsOfFile:info][kCompatibilityUUIDKey];
}

#pragma mark - public

+ (NSArray*) installedPlugins {

  return plugs = plugs ?: ({
    NSError* error = nil;
    id x = [[FM contentsOfDirectoryAtPath:self.pluginsDirectoryPath error:&error] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
      return [evaluatedObject hasSuffix:kXcodePluginSuffix];
    }]];
    if (!x || error) NSLog(@"error getting plugin files at path %@: %@", self.pluginsDirectoryPath, error);
    x;
  });
}

+ (NSArray*) allCompatibilityUUIDs {

  return uuids = uuids ?: ({
    NSMutableArray *pot = @[].mutableCopy;
    for (id path in self.installedXcodes) {
      NSString *uuid = [self _cuuidsForXcode:path];
      if (uuid) [pot addObject:uuid];
    }
    [pot copy];
  });
}

+ (NSArray *) installedXcodes {

  return xcodes = xcodes ?: ({
    CFArrayRef result = LSCopyApplicationURLsForBundleIdentifier(CFSTR("com.apple.dt.Xcode"), nil);
    !result ? nil : [(__bridge NSArray*) result valueForKeyPath:@"path"];
  });
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
  [self _notify: fixed.count ? [fixed componentsJoinedByString:@" "] : @"All Plugins OK"];
}

+ (NSString*) pluginsDirectoryPath
{
  return plugPath = plugPath ?: [NSURL fileURLWithPath:kPluginsDirectoryPath.stringByStandardizingPath.stringByResolvingSymlinksInPath.stringByExpandingTildeInPath isDirectory:YES].path;
}

void mycallback(
  ConstFSEventStreamRef streamRef,
  void *clientCallBackInfo,
  size_t numEvents,
  void *eventPaths,
  const FSEventStreamEventFlags eventFlags[],
  const FSEventStreamEventId eventIds[])
{

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

+ (void) _notify:(NSString*) reason {



  id notifier = [[[NSBundle bundleForClass:self] pathForAuxiliaryExecutable:@"DVTCompatibilitizer.notfier.app"] stringByAppendingPathComponent:@"Contents/MacOS/applet"];
  id title = NSStringFromClass(self);
  id r = reason ?: @"DVTCompatibilitized!";
  id cmd = [NSString stringWithFormat:@"title=\"%@\" message=\"%@\" \"%@\"", title, r, notifier];
  NSLog(@"running: %@", cmd);
  system([cmd UTF8String]);
//    NSUserNotification *notification = NSUserNotification.new;
//    notification.title = NSStringFromClass(self);
//    notification.informativeText = r;
//    notification.soundName = @"Sosumi";
//    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
}

+ (void) watchAndFixPluginsAsNeeded {

  NSArray *paths = [self.installedXcodes arrayByAddingObjectsFromArray:@[self.pluginsDirectoryPath]];

  // CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
  FSEventStreamContext *callbackInfo = NULL;

  CFAbsoluteTime latency = 10.;
  FSEventStreamRef stream = FSEventStreamCreate(NULL, &mycallback, callbackInfo,
                                               (__bridge CFArrayRef)paths,
                  kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                                latency,
                   kFSEventStreamCreateFlagNone); /* Flags explained in reference */

   FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
   FSEventStreamStart(stream);
   CFRunLoopRun();
}

@end

