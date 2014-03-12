#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDReversedValueTransformerMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)innerMapper valueTransformer:(NSValueTransformer *)valueTransformer;

@end

/*! Constructs a mapper that uses the reverseTransformValue from an NSValueTransformer to map values.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 *  @params valueTransformerName The name of the value transformer to look up and use.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapReverseValue(id<HYDMapper> mapper, NSString *valueTransformerName)
HYD_REQUIRE_NON_NIL(2);

/*! Constructs a mapper that uses the reverseTransformValue from an NSValueTransformer to map values.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 *  @params valueTransformer The value transformer instance to use to map values.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapReverseValue(id<HYDMapper> mapper, NSValueTransformer *valueTransformer)
HYD_REQUIRE_NON_NIL(2);

/*! Constructs a mapper that uses the reverseTransformValue from an NSValueTransformer to map values.
 *
 *  @params valueTransformerName The name of the value transformer to look up and use.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapReverseValue(NSString *valueTransformerName)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that uses the reverseTransformValue from an NSValueTransformer to map values.
 *
 *  @params valueTransformer The value transformer instance to use to map values.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapReverseValue(NSValueTransformer *valueTransformer)
HYD_REQUIRE_NON_NIL(1);
