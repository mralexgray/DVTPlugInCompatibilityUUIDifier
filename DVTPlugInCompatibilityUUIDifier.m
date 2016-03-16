
/*! @brief This class loads - when Xcode decides it wants to allow this plugin to startup.
    @note Please see enclosed README for important implementation details.
*/

@import Foundation;

extern BOOL launchWatchDog();

@interface			DVTPlugInCompatibilityUUIDifier : NSObject @end
@implementation DVTPlugInCompatibilityUUIDifier

+ (void) pluginDidLoad:(NSBundle*)me {

	static id x = nil; static dispatch_once_t token; dispatch_once(&token,^{ x = self.new; });
}

- init { return self = super.init ? launchWatchDog(), self : nil; }

@end

//  NSLog(@"[%@] LOADED: %@  Error: %@", NSStringFromClass(self.class), loaded ?  @"YES" : @"NO", error);
