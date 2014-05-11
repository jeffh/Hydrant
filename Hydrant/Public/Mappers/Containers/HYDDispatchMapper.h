#import "HYDBase.h"
#import "HYDMapper.h"


/*! Allows using a specific mapper based on the incoming source type.
 *
 *  @warning Alpha - API may subject to change in future versions.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDispatch(NSArray *mappingTuple)
HYD_REQUIRE_NON_NIL(1);
