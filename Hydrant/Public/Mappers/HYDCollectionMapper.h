#import "HYDMapper.h"
#import "HYDBase.h"


/*! Handles mapping between collections of items.
 *
 *  Uses the ItemMapper to map items from sourceCollection to destinationCollection.
 *  Collections are assumed to be the types as specified. If you want stronger type
 *  checking, use HYDTypedMapper.
 *
 *  @see HYDTypedMapper which adds stronger type checking
 *  @see HYDMapArrayOf, HYDMapSetOf helper constructors
 *  @see HYDMutableCollection for the required methods for destination collection classes.
 *  @see HYDCollection for the required methods for the source collection class.
 */
@interface HYDCollectionMapper : NSObject <HYDMapper>

- (id)initWithItemMapper:(id<HYDMapper>)wrappedMapper
   sourceCollectionClass:(Class)sourceCollectionClass
destinationCollectionClass:(Class)destinationCollectionClass;

@end


/*! Returns a mapper from two NSArrays where itemMapper can map each element between
 *  the two arrays.
 *
 *  @param itemMapper another mapper that can map the items in each array individually.
 *  @returns A HYDCollectionMapper that can do the conversion.
 */
HYD_EXTERN
HYDCollectionMapper *HYDMapArrayOf(id<HYDMapper> itemMapper)
HYD_REQUIRE_NON_NIL(1);
