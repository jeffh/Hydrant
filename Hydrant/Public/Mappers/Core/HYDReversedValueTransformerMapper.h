#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDReversedValueTransformerMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)innerMapper valueTransformer:(NSValueTransformer *)valueTransformer;

@end


HYD_EXTERN_OVERLOADED
HYDReversedValueTransformerMapper *HYDMapReverseValue(NSString *destinationKey, NSString *valueTransformerName)
HYD_REQUIRE_NON_NIL(2);


HYD_EXTERN_OVERLOADED
HYDReversedValueTransformerMapper *HYDMapReverseValue(NSString *destinationKey, NSValueTransformer *valueTransformer)
HYD_REQUIRE_NON_NIL(2);
