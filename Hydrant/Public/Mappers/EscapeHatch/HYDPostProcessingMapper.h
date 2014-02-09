#import "HYDMapper.h"
#import "HYDBase.h"


typedef void(^HYDPostProcessingBlock)(id sourceObject, id resultingObject, __autoreleasing HYDError **error);


@interface HYDPostProcessingMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper processBlock:(HYDPostProcessingBlock)block reverseProcessBlock:(HYDPostProcessingBlock)reverseBlock;

@end


/*! Constructs a HYDPostProcessingMapper that accepts two blocks to post-mutate the resulting object given the source object.
 *  The second block is used for reverse mapping.
 *
 *  @warning Use this mapper as a last resort, as they do not provide little error handling
 *           semantics like other mappers. The block you provide will have to do all the
 *           error checking of the incoming object and emitting the correct HYDErrors.
 *
 *  @param mapper the inner mapper that does the initial transformation.
 *  @param block the block that mutates the resultingObject based on the source object.
 *  @param reverseBlock the block that mutates the resultingObject based on the source object for the reverse mapper.
 *  @returns a mapper that can uses the block to map objects.
 */
HYD_EXTERN
HYD_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(id<HYDMapper> mapper, HYDPostProcessingBlock block, HYDPostProcessingBlock reverseBlock);


/*! Constructs a HYDPostProcessingMapper that accepts a block to post-mutate the resulting object given the source object.
 *  It's worth noting that the given block is also used for reverse mapping.
 *
 *  @warning Use this mapper as a last resort, as they do not provide little error handling
 *           semantics like other mappers. The block you provide will have to do all the
 *           error checking of the incoming object and emitting the correct HYDErrors.
 *
 *  @param mapper the inner mapper that does the initial transformation.
 *  @param block the block that mutates the resultingObject based on the source object.
 *  @returns a mapper that can uses the block to map objects.
 */
HYD_EXTERN
HYD_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(id<HYDMapper> mapper, HYDPostProcessingBlock block);


/*! Constructs a HYDPostProcessingMapper that accepts a block to post-mutate the resulting object given the source object.
 *  It's worth noting that the given block is also used for reverse mapping.
 *
 *  @warning Use this mapper as a last resort, as they do not provide little error handling
 *           semantics like other mappers. The block you provide will have to do all the
 *           error checking of the incoming object and emitting the correct HYDErrors.
 *
 *  @param destinationAccessor the property hint to the parent mapper to indicate
 *                        where to place the returned value.
 *  @param block the block that mutates the resultingObject based on the source object.
 *  @returns a mapper that can uses the block to map objects.
 */
HYD_EXTERN
HYD_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(NSString *destinationKey, HYDPostProcessingBlock block);
