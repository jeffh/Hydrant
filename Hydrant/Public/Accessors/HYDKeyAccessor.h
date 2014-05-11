#import "HYDBase.h"


@protocol HYDAccessor;


/*! Constructs an accessor that operates on the given KVC fields that conform to a Key.
 *
 *  This accessor uses -[valueForKey:] & -[setValue:forKey:] internally.
 */
HYD_EXTERN
id<HYDAccessor> HYDAccessKeyFromArray(NSArray *fields)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs an accessor that operates on the given KVC fields that conform to a Key.
 *
 *  This accessor uses -[valueForKey:] & -[setValue:forKey:] internally.
 */
#define HYDAccessKey(...) HYDAccessKeyFromArray([NSArray arrayWithObjects:__VA_ARGS__, nil])
