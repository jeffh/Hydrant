#import "HYDBase.h"
#import "HYDMapper.h"


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


/*! Returns a mapper from two collections where itemMapper can map each element between
 *  the two collections.
 *
 *  @param itemMapper another mapper that can map the items in each array individually.
 *  @param sourceCollectionClass the incoming collection source type
 *  @param destinationCollectionClass the resulting collection type generated
 *  @returns A HYDCollectionMapper that can do the conversion.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapCollectionOf(id<HYDMapper> itemMapper, Class sourceCollectionClass, Class destinationCollectionClass)
HYD_REQUIRE_NON_NIL(1,2,3);


/*! Returns a mapper from two collections where itemMapper can map each element between
 *  the two collections.
 *
 *  @param sourceCollectionClass the incoming collection source type
 *  @param destinationCollectionClass the resulting collection type generated
 *  @returns A HYDCollectionMapper that can do the conversion.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapCollectionOf(Class collectionClass)
HYD_REQUIRE_NON_NIL(1);


/*! Returns a mapper from two collections where itemMapper can map each element between
 *  the two collections.
 *
 *  @param sourceCollectionClass the incoming collection source type
 *  @param destinationCollectionClass the resulting collection type generated
 *  @returns A HYDCollectionMapper that can do the conversion.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapCollectionOf(Class sourceCollectionClass, Class destinationCollectionClass)
HYD_REQUIRE_NON_NIL(1,2);


/*! Returns a mapper from two collections where itemMapper can map each element between
 *  the two collections.
 *
 *  @param itemMapper another mapper that can map the items in each array individually.
 *  @param collectionClass the class that contains the items that need to be mapped. The resulting object is the same type.
 *  @returns A HYDCollectionMapper that can do the conversion.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapCollectionOf(id<HYDMapper> itemMapper, Class collectionClass)
HYD_REQUIRE_NON_NIL(1,2);


/*! Returns a mapper from two NSArrays where itemMapper can map each element between
 *  the two arrays.
 *
 *  @param itemMapper another mapper that can map the items in each array individually.
 *  @returns A HYDCollectionMapper that can do the conversion.
 */
HYD_EXTERN
id<HYDMapper> HYDMapArrayOf(id<HYDMapper> itemMapper)
HYD_REQUIRE_NON_NIL(1);


/*! Returns a mapper from two NSArrays where itemMapper can map each element between
 *  the two arrays. Shorthand for composing HYDMapArrayOf(HYDMapObject(...)).
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapArrayOfObjects(Class sourceItemClass, Class destinationItemClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3);


/*! Returns a mapper from two NSArrays where itemMapper can map each element between
 *  the two arrays. Shorthand for composing HYDMapArrayOf(HYDMapObject(...)).
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapArrayOfObjects(Class destinationItemClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2);
