#import "HYDBase.h"
#import "HYDMapper.h"

typedef id(^HYDConversionBlock)(id incomingValue, __autoreleasing HYDError **error);

@interface HYDBlockMapper : NSObject <HYDMapper>

- (id)initWithDestinationKey:(NSString *)destinationKey convertBlock:(HYDConversionBlock)convertBlock reverseBlock:(HYDConversionBlock)reverseConvertBlock;

@end

HYD_EXTERN
HYD_OVERLOADED
HYDBlockMapper *HYDMapWithBlock(NSString *destinationKey, HYDConversionBlock convertBlock)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN
HYD_OVERLOADED
HYDBlockMapper *HYDMapWithBlock(NSString *destinationKey, HYDConversionBlock convertBlock, HYDConversionBlock reverseConvertBlock)
HYD_REQUIRE_NON_NIL(2,3);
