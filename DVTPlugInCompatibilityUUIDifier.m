
#import "AHLaunchCtl.h"

@interface			DVTPlugInCompatibilityUUIDifier : NSObject @end
@implementation DVTPlugInCompatibilityUUIDifier


+ (void) pluginDidLoad:(NSBundle*)me {

  static id sharedPlugin = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ sharedPlugin = self.new; });
}

- init {

  if (!(self = super.init)) return nil;

  NSError   * error = nil;
  NSBundle * bundle = [NSBundle bundleForClass:self.class];
  id        jobname = bundle.bundleIdentifier,
					 watchdog = [bundle pathForAuxiliaryExecutable:@"DVTPlugInCompatibilityWatchdog"];

  [AHLaunchCtl.sharedController unload:jobname inDomain:kAHUserLaunchAgent error:&error];

  AHLaunchJob    * job = AHLaunchJob.new;
  job.Program          = watchdog;
  job.Label            = jobname;
  job.ProgramArguments = @[watchdog];
  job.RunAtLoad        = YES;

	[AHLaunchCtl.sharedController add:job toDomain:kAHUserLaunchAgent error:&error];

//  NSLog(@"[%@] LOADED: %@  Error: %@", NSStringFromClass(self.class), loaded ?  @"YES" : @"NO", error);

  return self;
}

@end

