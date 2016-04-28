
/*! @brief      This class loads - when Xcode decides it wants to allow this plugin to startup.
    @note       Please see enclosed README for important implementation details.
    @discussion Theoretically, this plugin doesn't need to do ANYTHING.  
                The watchdog should theoretically ALWAYS be running after first installed.
                This plug-in simply ensures it IS running, every time Xcode launches.
*/

@import         Foundation;
extern BOOL     launchWatchDog(); // Installs launch agent, etc.

@interface			DVTPlugInCompatibilityUUIDifier : NSObject @end
@implementation DVTPlugInCompatibilityUUIDifier

+ (void) pluginDidLoad:(NSBundle*)me {

  static dispatch_once_t tkn; dispatch_once(&tkn,^{ launchWatchDog(); });

//	static id x = nil; static dispatch_once_t tkn; dispatch_once(&tkn,^{ x = self.new; });
}

//- init { return self = super.init ? launchWatchDog(), self : nil; }

@end

//  NSLog(@"[%@] LOADED: %@  Error: %@", NSStringFromClass(self.class), loaded ?  @"YES" : @"NO", error);
