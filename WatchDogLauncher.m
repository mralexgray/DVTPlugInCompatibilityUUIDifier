
#import "AHLaunchCtl.h"

#define BUNDLE_CLASS @"DVTPlugInCompatibilityUUIDifier"
#define WATCHDOG_EXE @"DVTPlugInCompatibilityWatchdog"
#define IS_OK(X) (char*)(X ? "OK" : "FAIL")

BOOL launchWatchDog() {

  NSError * e = nil;
  id  // bpath = [NSProcessInfo.processInfo.arguments[0] stringByDeletingLastPathComponent].stringByDeletingLastPathComponent.stringByDeletingLastPathComponent,
		//	bundle = [NSBundle bundleWithPath:bpath] ?:
      bundle = [NSBundle bundleForClass:NSClassFromString(BUNDLE_CLASS)],
		 jobname = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"],
    watchdog = [bundle pathForAuxiliaryExecutable:WATCHDOG_EXE];

	printf("[%s] %s %s %s\n", BUNDLE_CLASS.UTF8String, [bundle description].UTF8String, [jobname UTF8String], [watchdog UTF8String]);

//  if (
  [AHLaunchCtl.sharedController unload:jobname inDomain:kAHUserLaunchAgent error:&e];
// ) // Check for existing job.
//    return YES;
//  else
//		NSLog(@"[%@] Installing DVTPlugInCompatibilityUUIDifier (or at least it's not running!)", DVTPlugInCompatibilityUUIDifierCLASS);

  AHLaunchJob * job    = AHLaunchJob.new;
  job.Program          = watchdog;
  job.Label            = jobname;
  job.ProgramArguments = @[watchdog];
  job.RunAtLoad        = YES;

	BOOL add = [AHLaunchCtl.sharedController add:job toDomain:kAHUserLaunchAgent error:&e], launch = NO;
	if (add) launch = [AHLaunchCtl.sharedController start:jobname inDomain:kAHUserLaunchAgent error:&e];

	return printf("[%s] Watchdog add:%s launch:%s err:%s\n", BUNDLE_CLASS.UTF8String, IS_OK(add), IS_OK(launch), [e description].UTF8String), add && launch;
}
