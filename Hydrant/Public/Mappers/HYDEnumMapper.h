#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDEnumMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey mapping:(NSDictionary *)mapping;

@end


/*! Returns a mapper that converts maps the source values using mapping.
 *
 *  @warning It is assumed that keys and values are one-to-one. Having a key
 *           map to many values or vice-versa will break the reverse mapping
 *           capabilities of this mapper.
 *
 *  @param mapping A dictionary of mapping @{ sourceValue: destinationValue }. Must be one-to-one.
 *  @returns a HYDEnumMapper that using the given dictionary to map between values
 */
HYD_EXTERN
HYDEnumMapper *HYDMapEnum(NSString *dstKey, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2);
