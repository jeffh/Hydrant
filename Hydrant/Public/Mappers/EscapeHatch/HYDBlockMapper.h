#import "HYDBase.h"
#import "HYDMapper.h"

typedef id(^HYDConversionBlock)(id incomingValue, __autoreleasing HYDError **error);

@interface HYDBlockMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper
        convertBlock:(HYDConversionBlock)convertBlock
        reverseBlock:(HYDConversionBlock)reverseConvertBlock;

@end

/*! Constructs a HYDBlockMapper that accepts a block to convert a given value to-and-from.
 *  It's worth noting that the given block is also used for reverse mapping.
 *
 *  @warning Use this mapper as a last resort, as they do not provide error handling
 *           semantics like other mappers. The block you provide will have to do all the
 *           error checking of the incoming object and emitting the correct HYDErrors.
 *
 *  @param convertBlock the block the converts the incoming value or returns an error.
 *  @returns a mapper that can uses the block to map objects.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapWithBlock(HYDConversionBlock convertBlock)
HYD_REQUIRE_NON_NIL(1);


/*! Constructs a HYDBlockMapper that accepts two blocks to convert a given value to-and-from.
 *  The second block is used for reverse mapping.
 *
 *  @warning Use this mapper as a last resort, as they do not provide error handling
 *           semantics like other mappers. The block you provide will have to do all the
 *           error checking of the incoming object and emitting the correct HYDErrors.
 *
 *  @param convertBlock the block the converts the incoming value or returns an error.
 *  @param reverseConvertBlock the block the converts the incoming value when producing
 *                             a reverse mapper.
 *  @returns a mapper that can uses the block to map objects.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapWithBlock(HYDConversionBlock convertBlock, HYDConversionBlock reverseConvertBlock)
HYD_REQUIRE_NON_NIL(1,2);
