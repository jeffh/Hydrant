#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDReversedValueTransformerMapper : NSObject <HYDMapper>

- (id)initWithValueTransformer:(NSValueTransformer *)valueTransformer;

@end

/*! Constructs a mapper that uses the reverseTransformValue from an NSValueTransformer to map values.
 *
 *  @param mapper The mapper that processes the source value before this mapper.
 *  @param valueTransformerName The name of the value transformer to look up and use.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapReverseValue(id<HYDMapper> mapper, NSString *valueTransformerName)
HYD_REQUIRE_NON_NIL(2);

/*! Constructs a mapper that uses the reverseTransformValue from an NSValueTransformer to map values.
 *
 *  @param mapper The mapper that processes the source value before this mapper.
 *  @param valueTransformer The value transformer instance to use to map values.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapReverseValue(id<HYDMapper> mapper, NSValueTransformer *valueTransformer)
HYD_REQUIRE_NON_NIL(2);

/*! Constructs a mapper that uses the reverseTransformValue from an NSValueTransformer to map values.
 *
 *  @param valueTransformerName The name of the value transformer to look up and use.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapReverseValue(NSString *valueTransformerName)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that uses the reverseTransformValue from an NSValueTransformer to map values.
 *
 *  @param valueTransformer The value transformer instance to use to map values.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapReverseValue(NSValueTransformer *valueTransformer)
HYD_REQUIRE_NON_NIL(1);
