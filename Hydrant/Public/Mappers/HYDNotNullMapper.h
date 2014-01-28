#import "HYDBase.h"
#import "HYDMapper.h"

@interface HYDNotNullMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper;

@end

HYD_EXTERN
HYD_OVERLOADED
HYDNotNullMapper *HYDMapNotNull(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYD_OVERLOADED
HYDNotNullMapper *HYDMapNotNull(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);
