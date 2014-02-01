#import "HYDFactory.h"


/*! A basic factory that can produce an instance of any class by using
 *  the default NSObject constructor.
 *
 *  This factory uses mutableCopy to handle the case where immutable
 *  classes are given to it (eg - NSDictionary or NSArray).
 *
 *  In short, this factory does [[[theClass alloc] init] mutableCopy],
 *  where mutableCopy is optional (only if the class supports the
 *  NSMutableCopying protocol)
 *
 *  @see NSMutableCopying
 *
 */
@interface HYDObjectFactory : NSObject <HYDFactory>
@end
