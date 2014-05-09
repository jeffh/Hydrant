#import "HYDBase.h"
#import "HYDMapper.h"


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapSplit(id<HYDMapper> mapper, id<HYDMapper> reverseMapper)
HYD_REQUIRE_NON_NIL(1,2);
