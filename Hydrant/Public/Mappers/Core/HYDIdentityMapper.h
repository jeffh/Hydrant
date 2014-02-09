#import "HYDMapper.h"
#import "HYDBase.h"


@protocol HYDAccessor;


@interface HYDIdentityMapper : NSObject <HYDMapper>

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor;

@end


/*! A mapper that just returns the value it was given.
 *
 *  This is used internally by more complex mappers as a default
 *  mapper for ones not explicitly defined in their constructor syntax.
 *  A perfect example is the values of HYDKeyValueMapper's dictionary mapping.
 *
 *  @param destinationAccessor the property hint to the parent mapper to indicate where to place the returned value.
 *  @returns a mapper that returns any value its given.
 *
 *  @see HYDKeyValueMapper
 */
HYD_EXTERN
HYD_OVERLOADED
HYDIdentityMapper *HYDMapIdentity(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);

/*! A mapper that just returns the value it was given.
 *
 *  This is used internally by more complex mappers as a default
 *  mapper for ones not explicitly defined in their constructor syntax.
 *  A perfect example is the values of HYDKeyValueMapper's dictionary mapping.
 *
 *  @param destinationAccessor the property hint to the parent mapper to indicate where to place the returned value.
 *  @returns a mapper that returns any value its given.
 *
 *  @see HYDKeyValueMapper
 */
HYD_EXTERN
HYD_OVERLOADED
HYDIdentityMapper *HYDMapIdentity(id<HYDAccessor> destinationAccessor)
HYD_REQUIRE_NON_NIL(1);
