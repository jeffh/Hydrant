#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDEnumMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey mapping:(NSDictionary *)mapping;

@end


HYD_EXTERN
HYDEnumMapper *HYDEnum(NSString *dstKey, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2);
