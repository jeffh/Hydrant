#import "HYDBase.h"
#import "HYDMapper.h"


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapBackward(id<HYDAccessor> accessor, Class destinationClass, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2,3);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapBackward(NSString *destinationKey, Class destinationClass, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2,3);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapBackward(id<HYDAccessor> accessor, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapBackward(NSString *destinationKey, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2);
