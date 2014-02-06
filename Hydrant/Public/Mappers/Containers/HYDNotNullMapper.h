#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDNotNullMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper;

@end


/*! Creates a mapper that enforces values that pass through it to not be nil.
 *
 *  This is useful to ensure the given parameter is required to be not-nil.
 *  With mappers, such as HYDKeyValueMapper, you can ensure incoming JSON
 *  dictionaries are not nil (as the KeyValueMapper will convert NSNull to
 *  nils.
 *
 *  @param destinationKey The destinationKey to pass to HYDMapIdentity that is
 *                        wrapped with a HYDNotNullMapper
 *  @returns a HYDNotNullMapper instance that wraps a HYDIdentityMapper with
 *           the given destinationKey
 *  @see HYDMapObject
 *  @see HYDMapIdentity
 */
HYD_EXTERN
HYD_OVERLOADED
HYDNotNullMapper *HYDMapNotNull(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);


/*! Creates a mapper that enforces values that pass through it to not be nil.
 *
 *  This is useful to ensure the given parameter is required to be not-nil.
 *  With mappers, such as HYDKeyValueMapper, you can ensure incoming JSON
 *  dictionaries are not nil (as the KeyValueMapper will convert NSNull to
 *  nils.
 *
 *  @param mapper The mapper to enforce non-nil-ness.
 *  @returns a HYDNotNullMapper instance that wraps the given mapper
 *  @see HYDMapObject
 *  @see HYDMapIdentity
 */
HYD_EXTERN
HYD_OVERLOADED
HYDNotNullMapper *HYDMapNotNull(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);
