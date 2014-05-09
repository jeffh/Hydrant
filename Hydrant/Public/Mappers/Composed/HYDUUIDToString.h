#import "HYDBase.h"

@protocol HYDMapper;

/*! Constructs a mapper to convert UUIDs to strings.
 */
HYD_EXTERN
id<HYDMapper> HYDMapUUIDToString();

/*! Constructs a mapper to convert UUIDs to strings.
 *
 *  @param mapper The mapper that processes the source value before this mapper.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapUUIDToStringFrom(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);
