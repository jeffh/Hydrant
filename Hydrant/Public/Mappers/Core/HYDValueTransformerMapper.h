#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDValueTransformerMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)innerMapper valueTransformer:(NSValueTransformer *)valueTransformer;

@end


HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(id<HYDMapper> mapper, NSString *valueTransformerName)
HYD_REQUIRE_NON_NIL(2);


HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(id<HYDMapper> mapper, NSValueTransformer *valueTransformer)
HYD_REQUIRE_NON_NIL(2);


HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *destinationKey, NSString *valueTransformerName)
HYD_REQUIRE_NON_NIL(2);


HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *destinationKey, NSValueTransformer *valueTransformer)
HYD_REQUIRE_NON_NIL(2);
