
@import Foundation;

@interface DVTCompatibilitizer : NSObject

+ (void) watchAndFixPluginsAsNeeded;
+ (void) notify:reason;

@end
