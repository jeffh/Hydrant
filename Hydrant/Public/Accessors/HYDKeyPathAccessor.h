#import "HYDBase.h"
#import "HYDAccessor.h"


/*! This class uses KVC to retrieve and store values on objects.
 *
 *  The keys it accepts are the form that -[valueForKeyPath:] accepts.
 *
 *  Internally, -[valueForKeyPath:] and -[setValue:forKey:] are used
 *  to retrieve and populate objects.
 *
 *  @warning Do not use aggregating key path functions, as they are not
 *           supported when setting values on objects. Doing so will
 *           have undefined behavior.
 */
@interface HYDKeyPathAccessor : NSObject <HYDAccessor>

- (id)initWithKeyPaths:(NSArray *)keyPaths;

@end

/*! Constructs an accessor that operates on the given KVC fields that conform to a KeyPath.
 *
 *  This accessor uses -[valueForKeyPath:] & -[setValue:forKey:]
 */
HYD_EXTERN
HYDKeyPathAccessor *HYDAccessKeyPathFromArray(NSArray *keyPaths)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs an accessor that operates on the given KVC fields that conform to a KeyPath.
 *
 *  This accessor uses -[valueForKeyPath:] & -[setValue:forKey:]
 */
#define HYDAccessKeyPath(...) HYDAccessKeyPathFromArray([NSArray arrayWithObjects:__VA_ARGS__, nil])
