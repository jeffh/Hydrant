#import "HYDBase.h"
#import "HYDMapper.h"


/*! Creates a mapper that enforces values that pass through it to not be nil.
 *
 *  This is useful to ensure the given parameter is required to be not-nil.
 *  With mappers, such as HYDObjectMapper, you can ensure incoming JSON
 *  dictionaries are not nil (as the KeyValueMapper will convert NSNull to
 *  nils.
 *
 *  @returns a HYDNotNullMapper instance that wraps a HYDIdentityMapper with
 *           the given destinationAccessor
 *  @see HYDMapObject
 *  @see HYDMapIdentity
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNotNull(void);

/*! Creates a mapper that enforces values that pass through it to not be nil.
 *  Alias to HYDMapNotNull(innerMapper)
 *
 *  This is useful to ensure the given parameter is required to be not-nil.
 *  With mappers, such as HYDObjectMapper, you can ensure incoming JSON
 *  dictionaries are not nil (as the KeyValueMapper will convert NSNull to
 *  nils.
 *
 *  @param innerMapper The mapper to enforce non-nil-ness.
 *  @returns a HYDNotNullMapper instance that wraps the given mapper
 *  @see HYDMapObject
 *  @see HYDMapIdentity
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNotNullFrom(id<HYDMapper> innerMapper)
HYD_REQUIRE_NON_NIL(1);

/*! Creates a mapper that enforces values that pass through it to not be nil.
 *
 *  This is useful to ensure the given parameter is required to be not-nil.
 *  With mappers, such as HYDObjectMapper, you can ensure incoming JSON
 *  dictionaries are not nil (as the KeyValueMapper will convert NSNull to
 *  nils.
 *
 *  @param innerMapper The mapper to enforce non-nil-ness.
 *  @returns a HYDNotNullMapper instance that wraps the given mapper
 *  @see HYDMapObject
 *  @see HYDMapIdentity
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNotNull(id<HYDMapper> innerMapper)
HYD_REQUIRE_NON_NIL(1);
