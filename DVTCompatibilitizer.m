
/* This is the implementation for DVTPlugInCompatibilityWatchdog 

  1. This launchd "agent" runs all the time.
		It watches certain (which)? places for changes in your 
			- Xcode installations.
			- Plugin installtions.
		and reacts by..
			1. amassing a list of possibly needed DVTPlugInCompatibilityUUID's for your system.
			2. setting ALL plug-ins to have those DVTPlugInCompatibilityUUID's
			
			Run tests like.. 

				`./pathTo/DVTPlugInCompatibilityWatchdog test`

			Which runs all TESTABLES, below.
			
			In the xcode build scheme, this watychdog is run like ..
			
					`./pathTo/DVTPlugInCompatibilityWatchdog watchdog`
			
			right after being built AOK, to make sure the watchdog is running.
			This is exactly the same as what happens when the plugin loads.
*/
#define              TESTABLES  @[ @"watchPaths", @"installedPlugins", @"installedXcodes", @"pluginsDirectoryPath", @"fixPlugins"]

#define			kXcodePluginSuffix	@"xcplugin"
#define  kPluginsDirectoryPath	@"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
#define  kCompatibilityUUIDKey	@"DVTPlugInCompatibilityUUID"
#define kCompatibilityUUIDsKey  kCompatibilityUUIDKey @"s"
#define    kInfoPlistComponent	@"Contents/Info.plist"
#define                   ARGV  ((NSArray<NSString*>*)NSProcessInfo.processInfo.arguments)
#define											FM	NSFileManager.defaultManager


@import	      AppKit;
@import CoreServices;
@import	  ObjectiveC;

extern BOOL launchWatchDog();
typedef NS_OPTIONS(int,FixStatus) { FixOK = YES, FixAlreadyOK, FixNoPlist, FixErrorWriting };

//static NSDictionary * xcodes;
//static NSString *reason;

@interface			DVTCompatibilitizer : NSObject @end
@implementation DVTCompatibilitizer

#pragma mark - Static Info Fetchers (TESTABLE)

+ (NSArray*) watchPaths { // This is a list of places watched by FSEvents (TESTABLE)

	return [self.installedXcodes.allKeys arrayByAddingObjectsFromArray:@[self.pluginsDirectoryPath]];
}

+ (NSArray*) installedPlugins { // Amasses list of all installed xc plugins. (TESTABLE)

	return [[FM contentsOfDirectoryAtPath:self.pluginsDirectoryPath error:nil]
            filteredArrayUsingPredicate:
        [NSPredicate predicateWithBlock:^BOOL(NSString *z, id b) {

    return [z.pathExtension isEqualToString:kXcodePluginSuffix];  // only fetch .xcplugins

  }]];
}

+ (NSDictionary*) installedXcodes {  // Finds all your Xcode's (TESTABLE)

	CFArrayRef result = LSCopyApplicationURLsForBundleIdentifier(CFSTR("com.apple.dt.Xcode"), nil);

	id paths = !result ? nil : [(__bridge NSArray*) result valueForKeyPath:@"path"];

	if (!paths || ![paths count]) return nil;

	NSMutableDictionary *pot = @{}.mutableCopy;

	for (id path in paths) { NSString *uuid = [self _cUUIDForXcode:path]; if (uuid) pot[path] = uuid; }

	return pot.copy;
}

+ (NSString*) pluginsDirectoryPath { static NSString * plugPath; // As the name implies (TESTABLE)

  return plugPath = plugPath ?: [NSURL fileURLWithPath:kPluginsDirectoryPath.stringByStandardizingPath.stringByResolvingSymlinksInPath.stringByExpandingTildeInPath isDirectory:YES].path;
}

+ (NSArray*) fixPlugins { // check and fix out little babies.  (TESTABLE)

  NSMutableArray *fixed = @[].mutableCopy, *okalready = @[].mutableCopy, *errored = @[].mutableCopy;

  for (id x in self.installedPlugins) {

    id plpath = [[self.pluginsDirectoryPath stringByAppendingPathComponent:x]
                                            stringByAppendingPathComponent:kInfoPlistComponent];

    if (![FM fileExistsAtPath:plpath]) {
      NSLog(@"WARNING: Skipped %@, as it was missing.", plpath);
      [errored addObject:[plpath lastPathComponent]];
    }
    else {
      FixStatus stat = [self _fixPlistAtPath:plpath];
      id arr = stat == FixOK ? fixed : stat == FixAlreadyOK ? okalready : errored;
      [arr addObject:[x stringByDeletingPathExtension]];
    }
  }

 if (fixed.count) [self _notify:[NSString stringWithFormat:@"FIXED: %@.", [fixed componentsJoinedByString:@" "]]];
 if (errored.count) {
    [self _notify:[NSString stringWithFormat:@"ERROR: %lu plugins had problems.", errored.count]];
    NSLog(@"ERRORS with %@", [errored componentsJoinedByString:@" "]);
  }
  if (okalready.count) {
    if (!fixed.count) [self _notify:[NSString stringWithFormat:@"All %lu plugins are OK", self.installedPlugins.count]];
    NSLog(@"Didn't fix, already OK: %@!", [okalready componentsJoinedByString:@" "]);
  }
  return fixed.copy;
}

#pragma mark - Utility

+ (void) _notify:reason {  // Posts notifications on our behalf!

  id notifier = [[[NSBundle bundleForClass:self]
								pathForAuxiliaryExecutable:@"DVTCompatibilitizer.notfier.app"]
						stringByAppendingPathComponent:@"Contents/MacOS/applet"];

  system([[NSString stringWithFormat:@"title=\"%@\" message=\"%@\" \"%@\"", NSStringFromClass(self),
																																						reason ?: @"DVTCompatibilitized!",
																																						notifier] UTF8String]);
}

+ (BOOL) _keysAreOK:(NSArray*)pluginIDs { // Checks a single plugin's list of UUIDS making sure all of OUR Xcodes are there.

  __block BOOL missingUUID = NO;
  [self.installedXcodes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

    if (![pluginIDs containsObject:obj]) missingUUID = *stop = YES;

  }];
  return !missingUUID;
}

+ (NSString*) _cUUIDForXcode:(NSString*)path { // Get required "compatibility UUID" for a specific xcode

  return [NSDictionary dictionaryWithContentsOfFile:
							 [path stringByAppendingPathComponent:kInfoPlistComponent]][kCompatibilityUUIDKey];
}

#pragma mark - Watchdog

void _watchdogCallback( ConstFSEventStreamRef            streamRef,
												void *                  clientCallBackInfo,
												size_t                           numEvents,
												void *                          eventPaths,
												const FSEventStreamEventFlags eventFlags[],
												const FSEventStreamEventId      eventIds[]) {

  for(size_t i = 0; i < numEvents; i++) { /// flags are unsigned long, IDs are uint64_t

    id eventPath = [NSString stringWithUTF8String:((char**)eventPaths)[i]];

    if ([[eventPath lowercaseString] rangeOfString:@"notfier.app"].location != NSNotFound) continue;  // disregard notifier.

    NSLog(@"Change %llu in %@, flags %ui\n", eventIds[i], eventPath, ((unsigned int)eventFlags[i]));
    [DVTCompatibilitizer fixPlugins];
    break;
  }
//	if (![xcodes isEqualToDictionary:DVTCompatibilitizer.installedXcodes]) [DVTCompatibilitizer fixPlugins];
}

+ (BOOL) _watchAndFixPluginsAsNeeded { 	// Watch all known xcode

	[self _notify:@"Xcode Plugin watchdog running!"]; 	// Post user notifacatiion on launch.
  [DVTCompatibilitizer fixPlugins];

	CFAbsoluteTime			  latency = 30.;
  FSEventStreamContext * cbInfo = NULL;
  FSEventStreamRef       stream = FSEventStreamCreate(NULL,
																				&_watchdogCallback,
																										cbInfo,
											(__bridge CFArrayRef)self.watchPaths,
														 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
																									 latency,
														 kFSEventStreamCreateFlagNone); /* Flags explained in reference */

   FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
   FSEventStreamStart(stream);
   CFRunLoopRun();
	 return EXIT_SUCCESS;
}

+ (FixStatus) _fixPlistAtPath:plpath {

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithContentsOfFile:plpath];

		id cIDs = d[kCompatibilityUUIDsKey] ?: @[];

    if ([cIDs count] >= self.installedXcodes.count && [self _keysAreOK:cIDs])

      return FixAlreadyOK;

		cIDs = [NSMutableArray arrayWithArray:cIDs];

    [cIDs addObjectsFromArray:self.installedXcodes.allValues];

    d[kCompatibilityUUIDsKey] = [NSSet setWithArray:cIDs].allObjects;

		return [d writeToFile:plpath atomically:NO] ?: FixErrorWriting;
}

#pragma mark - Tests

+ (BOOL) _runTests {

	BOOL(^runTest)(id) = ^BOOL(id method){

		printf("\nTesting: [%s %s]\n\n", NSStringFromClass(self).UTF8String, [method description].UTF8String);

		SEL todo = NSSelectorFromString(method);

		if (![(id)self respondsToSelector:todo]) return NO;

		id (*objc_msgSendTyped)(id, SEL) = (id(*)(id,SEL))objc_msgSend; // (void*)objc_msgSend;

		id x = objc_msgSendTyped(self, todo);

		return x ? printf("%s\n", [x description].UTF8String), YES : NO;
	};

  for (id x in [ARGV[1] containsString:@"test"] ? TESTABLES : @[ARGV[1]])
    if (!runTest(x)) return NO; return YES;
}
@end

BOOL usage () { return printf(
"  USAGE: %s [option]\n"
"      help  this message\n"
"      test  run all tests\n"
"   OR any of the following to run a single test...\n"
"      %s", ARGV[0].lastPathComponent.UTF8String, [TESTABLES componentsJoinedByString:@"\n      "].UTF8String);
}

int main() { @autoreleasepool {

  if (ARGV.count == 1) return DVTCompatibilitizer._watchAndFixPluginsAsNeeded;

  id arg = ARGV[1].lowercaseString;

  return [arg containsString: @"dog"] ? launchWatchDog() // on first run
       : [arg containsString:@"help"] ? usage()
                                      : DVTCompatibilitizer._runTests; // run tests otherwise.
	}
}
