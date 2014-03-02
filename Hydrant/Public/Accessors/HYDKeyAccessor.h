#import "HYDBase.h"
#import "HYDAccessor.h"

/*! This class uses KVC to retrieve and store values on objects.
 *
 *  The keys it accepts are the form that -[valueForKey:] accepts.
 *
 *  Internally, -[valueForKey:] and -[setValue:forKey:] are used
 *  to retrieve and populate objects.
 */
@interface HYDKeyAccessor : NSObject <HYDAccessor>

- (id)initWithKeys:(NSArray *)keys;

@end


/*! Constructs an accessor that operates on the given KVC fields that conform to a Key.
 *
 *  This accessor uses -[valueForKey:] & -[setValue:forKey:]
 */
HYD_EXTERN
HYDKeyAccessor *HYDAccessKeyFromArray(NSArray *fields)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs an accessor that operates on the given KVC fields that conform to a Key.
 *
 *  This accessor uses -[valueForKey:] & -[setValue:forKey:]
 */
#define HYDAccessKey(...) HYDAccessKeyFromArray([NSArray arrayWithObjects:__VA_ARGS__, nil])
