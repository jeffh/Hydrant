#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDEnumMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper mapping:(NSDictionary *)mapping;

@end


/*! Returns a mapper that converts maps the source values using mapping.
 *
 *  @warning It is assumed that keys and values are one-to-one. Having a key
 *           map to many values or vice-versa will break the reverse mapping
 *           capabilities of this mapper.
 *
 *  @param destinationAccessor the property hint to the parent mapper to indicate
 *                        where to place the returned value.
 *  @param mapping A dictionary of mapping @{ sourceValue: destinationValue }. Must be one-to-one.
 *  @returns a HYDEnumMapper that using the given dictionary to map between values
 */
HYD_EXTERN_OVERLOADED
HYDEnumMapper *HYDMapEnum(NSString *destinationKey, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2);


/*! Returns a mapper that converts maps the source values using mapping.
 *
 *  @warning It is assumed that keys and values are one-to-one. Having a key
 *           map to many values or vice-versa will break the reverse mapping
 *           capabilities of this mapper.
 *
 *  @param mapper The inner mapper to extract the value from. The inner mapper also
 *                stores destination accessor.
 *  @param mapping A dictionary of mapping @{ sourceValue: destinationValue }. Must be one-to-one.
 *  @returns a HYDEnumMapper that using the given dictionary to map between values
 */
HYD_EXTERN_OVERLOADED
HYDEnumMapper *HYDMapEnum(id<HYDMapper> mapper, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(1,2);
