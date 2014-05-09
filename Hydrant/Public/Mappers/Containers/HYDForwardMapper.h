#import "HYDBase.h"
#import "HYDMapper.h"


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(id<HYDAccessor> accessor, Class sourceClass, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2,3);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(NSString *walkKey, Class sourceClass, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2,3);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(id<HYDAccessor> accessor, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(NSString *walkKey, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2);
