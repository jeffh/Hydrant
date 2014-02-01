#import "HYDBase.h"
#import "HYDNonFatalMapper.h"
#import "HYDNotNullMapper.h"

// TODO: test these methods?

HYD_EXTERN
HYD_OVERLOADED
id<HYDMapper> HYDMapOptionally(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);


HYD_EXTERN
HYD_OVERLOADED
id<HYDMapper> HYDMapOptionally(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);


HYD_EXTERN
HYD_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefault(NSString *destinationKey, id defaultValue)
HYD_REQUIRE_NON_NIL(1);


HYD_EXTERN
HYD_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefault(id<HYDMapper> mapper, id defaultValue)
HYD_REQUIRE_NON_NIL(1);


HYD_EXTERN
HYD_OVERLOADED
id<HYDMapper> HYDMapOptionallyWithDefaultAndReversedDefault(id<HYDMapper> mapper, id defaultValue, id reverseDefaultValue)
HYD_REQUIRE_NON_NIL(1);
