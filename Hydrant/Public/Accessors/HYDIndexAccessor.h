#import "HYDBase.h"


@protocol HYDAccessor;


/*! Constructs an accessor that operates on the given KVC fields that conform to a Key.
 *
 *  This accessor uses -[valueForKey:] & -[setValue:forKey:]
 */
HYD_EXTERN
id<HYDAccessor> HYDAccessIndiciesFromArray(NSArray *indicies)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs an accessor that operates on the given KVC fields that conform to a Key.
 *
 *  This accessor uses -[valueForKey:] & -[setValue:forKey:]
 */
#define HYDAccessIndex(...) HYDAccessIndiciesFromArray([NSArray arrayWithObjects:__VA_ARGS__, nil])
