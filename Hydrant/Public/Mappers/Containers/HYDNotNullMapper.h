#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDNotNullMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper;

@end


/*! Creates a mapper that enforces values that pass through it to not be nil.
 *
 *  This is useful to ensure the given parameter is required to be not-nil.
 *  With mappers, such as HYDObjectMapper, you can ensure incoming JSON
 *  dictionaries are not nil (as the KeyValueMapper will convert NSNull to
 *  nils.
 *
 *  @param destinationAccessor The destinationAccessor to pass to HYDMapIdentity that is
 *                        wrapped with a HYDNotNullMapper
 *  @returns a HYDNotNullMapper instance that wraps a HYDIdentityMapper with
 *           the given destinationAccessor
 *  @see HYDMapObject
 *  @see HYDMapIdentity
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNotNull(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);


/*! Creates a mapper that enforces values that pass through it to not be nil.
 *
 *  This is useful to ensure the given parameter is required to be not-nil.
 *  With mappers, such as HYDObjectMapper, you can ensure incoming JSON
 *  dictionaries are not nil (as the KeyValueMapper will convert NSNull to
 *  nils.
 *
 *  @param mapper The mapper to enforce non-nil-ness.
 *  @returns a HYDNotNullMapper instance that wraps the given mapper
 *  @see HYDMapObject
 *  @see HYDMapIdentity
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNotNull(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);
