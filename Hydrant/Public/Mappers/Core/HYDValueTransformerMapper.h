#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDValueTransformerMapper : NSObject <HYDMapper>

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor valueTransformer:(NSValueTransformer *)valueTransformer;

@end


HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *destinationKey, NSString *valueTransformerName)
HYD_REQUIRE_NON_NIL(1);


HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *destinationKey, NSValueTransformer *valueTransformer)
HYD_REQUIRE_NON_NIL(1);
