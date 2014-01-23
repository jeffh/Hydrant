#import "HYDMapper.h"
#import "HYDBase.h"


@class HYDObjectFactory;

typedef id(^HYDValueBlock)();


@interface HYDOptionalMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper defaultValue:(HYDValueBlock)defaultValue reverseDefaultValue:(HYDValueBlock)reverseDefaultValue;

@end


HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDOptional(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDOptional(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDOptionalWithDefault(id<HYDMapper> mapper, id defaultValue)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYD_OVERLOADED
HYDOptionalMapper *HYDOptionalWithDefault(NSString *destinationKey, id defaultValue)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYDOptionalMapper *HYDOptionalWithDefaultAndReversedDefault(id<HYDMapper> mapper, id defaultValue, id reversedDefault)
HYD_REQUIRE_NON_NIL(1);
