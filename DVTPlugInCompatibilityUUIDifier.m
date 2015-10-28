
//  DVTPlugInCompatibilityUUIDifier.m

#import "AHLaunchCtl.h"

@import Foundation;

#define PLUGIN_NAME @"DVTPlugInCompatibilityUUIDifier"

@interface DVTPlugInCompatibilityUUIDifier : NSObject
@end

@implementation DVTPlugInCompatibilityUUIDifier

+ (void) initialize {

  NSLog(@"[" PLUGIN_NAME "] INITIALIZED");
//  NSLog(@"[" PLUGIN_NAME "] Plugins: %@", DVTCompatibilitizer.installedPlugins);
//  NSLog(@"[" PLUGIN_NAME "] UUIDS: %@",   DVTCompatibilitizer.allCompatibilityUUIDs);
}

+ (void)pluginDidLoad:(NSBundle*)plugin
{
  static id sharedPlugin = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ sharedPlugin = self.new; });
}

- init {

  if (!(self = super.init)) return nil;

//  [DVTCompatibilitizer fixPlugins];

  NSError *error = nil;
  id jobname = [NSBundle bundleForClass:self.class].bundleIdentifier;
  id watchdog = [[NSBundle bundleForClass:self.class] pathForAuxiliaryExecutable:@"DVTPlugInCompatibilityWatchdog"];

//  NSLog(@"watchdog path: %@", watchdog);
  [AHLaunchCtl.sharedController unload:jobname inDomain:kAHUserLaunchAgent error:&error];

  AHLaunchJob* job = AHLaunchJob.new;

  job.Program = watchdog;
  job.Label = jobname;
  job.ProgramArguments = @[watchdog];
//  job.StandardOutPath = @"/tmp/hello.txt";
  job.RunAtLoad = YES;
//  job.StartCalendarInterval = [AHLaunchJobSchedule dailyRunAtHour:2 minute:00];

  // All sharedController methods return BOOL values.
  // `YES` for success, `NO` on failure (which will also populate an NSError).
  BOOL loaded = [AHLaunchCtl.sharedController add:job
                             toDomain:kAHUserLaunchAgent
                                error:&error];

  NSLog(@"[" PLUGIN_NAME "] LOADED: %@  Error: %@", loaded ?  @"YES" : @"NO", error);

  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:)
  //                                                   name:NSApplicationDidFinishLaunchingNotification object:nil];
  return self;
}

@end

