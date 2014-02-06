#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDReversedValueTransformerMapper : NSObject <HYDMapper>

- (id)initWithDestinationKey:(NSString *)destinationKey valueTransformer:(NSValueTransformer *)valueTransformer;

@end


HYD_EXTERN
HYD_OVERLOADED
HYDReversedValueTransformerMapper *HYDMapReverseValue(NSString *destinationKey, NSString *valueTransformerName)
HYD_REQUIRE_NON_NIL(2);


HYD_EXTERN
HYD_OVERLOADED
HYDReversedValueTransformerMapper *HYDMapReverseValue(NSString *destinationKey, NSValueTransformer *valueTransformer)
HYD_REQUIRE_NON_NIL(2);
