#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDValueTransformerMapper : NSObject <HYDMapper>

@property (copy, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey valueTransformer:(NSValueTransformer *)valueTransformer;

@end

HYD_EXTERN
HYD_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *destinationKey, NSString *valueTransformerName)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYD_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *destinationKey, NSValueTransformer *valueTransformer)
HYD_REQUIRE_NON_NIL(1);