#import "HYDBase.h"

@protocol HYDMapper;

/*! Constructs a mapper to convert strings to UUIDs.
 */
HYD_EXTERN
id<HYDMapper> HYDMapStringToUUID(void);

/*! Constructs a mapper to convert strings to UUIDs.
 *
 *  @param mapper The mapper that processes the source value before this mapper.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToUUIDFrom(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);
