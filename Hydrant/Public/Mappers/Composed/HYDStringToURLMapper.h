#import "HYDBase.h"

@protocol HYDMapper;

/*! Constructs a mapper that maps strings to URLs.
 */
HYD_EXTERN
id<HYDMapper> HYDMapStringToURL(void);

/*! Constructs a mapper that maps strings to URLs.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLFrom(id<HYDMapper> mapper);

/*! Constructs a mapper that maps strings to URLs.
 *
 *  @params destinationKey The property hint to where the place the mapped value to for other mappers.
 *  @params allowedSchemes The set of allowed schemes for this mapper to accept.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);

/*! Constructs a mapper that maps strings to URLs.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 *  @params allowedSchemes The set of allowed schemes for this mapper to accept.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);
