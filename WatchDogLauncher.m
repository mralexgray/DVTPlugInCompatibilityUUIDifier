
#import "AHLaunchCtl.h"

#define DVTPlugInCompatibilityUUIDifierCLASS @"DVTPlugInCompatibilityUUIDifier"
#define OK(X) (char*)(X ? "OK" : "FAIL")

BOOL launchWatchDog() {

  NSError * e = nil;
  id   bpath = [NSProcessInfo.processInfo.arguments[0] stringByDeletingLastPathComponent].stringByDeletingLastPathComponent.stringByDeletingLastPathComponent,
			bundle = [NSBundle bundleWithPath:bpath] ?: [NSBundle bundleForClass:NSClassFromString(DVTPlugInCompatibilityUUIDifierCLASS)],
		 jobname = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"],
    watchdog = [bundle pathForAuxiliaryExecutable:@"DVTPlugInCompatibilityWatchdog"];

	printf("[%s] %s %s %s\n", DVTPlugInCompatibilityUUIDifierCLASS.UTF8String, [bundle description].UTF8String, [jobname UTF8String], [watchdog UTF8String]);

  if (![AHLaunchCtl.sharedController unload:jobname inDomain:kAHUserLaunchAgent error:&e]) // Check for existing job.
		NSLog(@"[%@] Installing DVTPlugInCompatibilityUUIDifier (or at least it's not running!)", DVTPlugInCompatibilityUUIDifierCLASS);

  AHLaunchJob    * job = AHLaunchJob.new;
  job.Program          = watchdog;
  job.Label            = jobname;
  job.ProgramArguments = @[watchdog];
  job.RunAtLoad        = YES;

	BOOL add = [AHLaunchCtl.sharedController add:job toDomain:kAHUserLaunchAgent error:&e], launch = NO;
	if (add) launch = [AHLaunchCtl.sharedController start:jobname inDomain:kAHUserLaunchAgent error:&e];

	return  printf("[%s] Watchdog add:%s launch:%s err:%s\n", DVTPlugInCompatibilityUUIDifierCLASS.UTF8String, OK(add), OK(launch), [e description].UTF8String), add && launch;
}
