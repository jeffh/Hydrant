#import "HYDMapper.h"
#import "HYDBase.h"


@class HYDObjectFactory;

typedef id(^HYDValueBlock)();


@interface HYDOptionalMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper defaultValue:(HYDValueBlock)defaultValue reverseDefaultValue:(HYDValueBlock)reverseDefaultValue;

@end


HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDMapOptionally(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDMapOptionally(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDMapOptionallyWithDefault(id<HYDMapper> mapper, id defaultValue)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDMapOptionallyWithDefault(NSString *destinationKey, id defaultValue)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYDOptionalMapper *HYDMapOptionallyWithDefaultAndReversedDefault(id<HYDMapper> mapper, id defaultValue, id reversedDefault)
HYD_REQUIRE_NON_NIL(1);
