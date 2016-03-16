
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
#define              TESTABLES  @"watchPaths installedPlugins installedXcodes pluginsDirectoryPath fixPlugins"

#define			kXcodePluginSuffix	@"xcplugin"
#define  kPluginsDirectoryPath	@"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
#define  kCompatibilityUUIDKey	@"DVTPlugInCompatibilityUUID"
#define kCompatibilityUUIDsKey  kCompatibilityUUIDKey @"s"
#define    kInfoPlistComponent	@"Contents/Info.plist"
#define                   ARGV  NSProcessInfo.processInfo.arguments
#define											FM	NSFileManager.defaultManager


@import	      AppKit;
@import CoreServices;
@import	  ObjectiveC;

extern BOOL launchWatchDog();
static NSDictionary * xcodes;

@interface			DVTCompatibilitizer : NSObject @end
@implementation DVTCompatibilitizer

#pragma mark - Static Info Fetchers

+ (NSArray*) watchPaths { // This is a list of places watched by FSEvents (TESTABLE)

	return [self.installedXcodes.allKeys arrayByAddingObjectsFromArray:@[self.pluginsDirectoryPath]];
}

+ (NSArray*) installedPlugins { // Amasses list of all installed xc plugins. (TESTABLE)

	return [[FM contentsOfDirectoryAtPath:self.pluginsDirectoryPath error:nil]
            filteredArrayUsingPredicate:
        [NSPredicate predicateWithBlock:^BOOL(NSString *z, id b) {

    return [z.pathExtension isEqualToString:kXcodePluginSuffix];

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

#pragma mark - Utility

+ (void) _notify:reason {  // Posts notifications on our behalf!

  id notifier = [[[NSBundle bundleForClass:self]
								pathForAuxiliaryExecutable:@"DVTCompatibilitizer.notfier.app"]
						stringByAppendingPathComponent:@"Contents/MacOS/applet"];

  system([[NSString stringWithFormat:@"title=\"%@\" message=\"%@\" \"%@\"", NSStringFromClass(self),
																																						reason ?: @"DVTCompatibilitized!",
																																						notifier] UTF8String]);
}

+ (BOOL) _keysAreOK:(NSArray*)pluginIDs {

  return ![self.installedXcodes.allValues  filteredArrayUsingPredicate:
																			 [NSPredicate predicateWithBlock:^BOOL(id _Nonnull x, NSDictionary<NSString *,id> * _Nullable b) {
    return ![pluginIDs containsObject:x];

  }]].count && [NSSet setWithArray:pluginIDs].allObjects.count == pluginIDs.count;
}

+ (NSString*) _cUUIDForXcode:(NSString*)path {

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

  NSLog(@"Fixing plugins due to some change!\n");

  for (int i = 0; i < numEvents; i++) { /// flags are unsigned long, IDs are uint64_t

		id eventPath = [NSString stringWithUTF8String:((char**)eventPaths)[i]];

		NSLog(@"Change %llu in %@, flags %ui\n", eventIds[i], eventPath, ((unsigned int)eventFlags[i]));

    if ([eventPath rangeOfString:@"DVTCompatibilitizer.notfier.app"].location == NSNotFound) // disregard notifier.
			[DVTCompatibilitizer fixPlugins];
  }

	if (![xcodes isEqualToDictionary:DVTCompatibilitizer.installedXcodes]) [DVTCompatibilitizer fixPlugins];
}

+ (BOOL) _watchAndFixPluginsAsNeeded { 	// Watch all known xcode

	[self _notify:@"Xcode Plugin watchdog running!"]; 	// Post user notifacatiion on launch.

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

+ (BOOL) _fixPlistAtPath:plpath {

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithContentsOfFile:plpath];

		id cIDs = d[kCompatibilityUUIDsKey];

    if (cIDs && [cIDs count] && [self _keysAreOK:cIDs])

      return NSLog(@"NOT fixing: %@... It's already ok!", plpath), NO;

		cIDs = cIDs ? [cIDs mutableCopy] : @[].mutableCopy;

    [cIDs addObjectsFromArray:self.installedXcodes.allValues];

    d[kCompatibilityUUIDsKey] = [NSSet setWithArray:cIDs].allObjects;

		return [d writeToFile:plpath atomically:YES];
}

+ (void) fixPlugins { // check and fix out little babies.  (TESTABLE)

  NSMutableArray *fixed = @[].mutableCopy;

  for (id x in self.installedPlugins) {

    id plpath = [[self.pluginsDirectoryPath stringByAppendingPathComponent:x]
																					  stringByAppendingPathComponent:kInfoPlistComponent];

    ![FM fileExistsAtPath:plpath] ? NSLog(@"WARNING: Skipped %@, as it was missing.", plpath)
																	: ![self _fixPlistAtPath:plpath]
																	?: [fixed addObject:[x stringByDeletingPathExtension]];
  }

  [self _notify: fixed.count ? [fixed componentsJoinedByString:@" "]
														 : [NSString stringWithFormat:@"All %lu plugins are OK", self.installedPlugins.count]];
}

#pragma mark - Tests

+ (BOOL) _runTests {

	BOOL(^runTest)(id) = ^BOOL(id method){

		printf("\nTesting: [%s %s]\n\n", NSStringFromClass(self).UTF8String, [method description].UTF8String);

		SEL todo = NSSelectorFromString(method);

		if (![(id)self respondsToSelector:todo]) return NO;

		id (*objc_msgSendTyped)(id, SEL) = (void*)objc_msgSend;

		id x = objc_msgSendTyped(self, todo);

		return x ? printf("%s\n", [x description].UTF8String), YES : NO;
	};

	BOOL(^runTests)(id) = ^BOOL(id methods){ __block BOOL pass = YES;

		return [methods enumerateObjectsUsingBlock:^(id x, NSUInteger i, BOOL * s) { *s = !(pass = runTest(x)); }], pass;
	};

	return runTests([ARGV[1] containsString:@"test"] ? [TESTABLES componentsSeparatedByString:@" "] : @[ARGV[1]]);

	//	@[@"pluginsDirectoryPath", ];
}

@end

int main() { @autoreleasepool {

		return ARGV.count == 1	? DVTCompatibilitizer._watchAndFixPluginsAsNeeded  // running without arguments
														: ({ BOOL ok = [[ARGV[1] lowercaseString] containsString:@"dog"] ? launchWatchDog() // on first run
																																														 : DVTCompatibilitizer._runTests; // run tests otherwise.
																 ok ? NSBeep() : nil; ok; });
	}
}
