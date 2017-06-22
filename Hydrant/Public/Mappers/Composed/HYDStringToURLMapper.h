#import "HYDBase.h"

@protocol HYDMapper;

/*! Constructs a mapper that maps strings to URLs.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURL(void);

/*! Constructs a mapper that maps strings to URLs.
 *
 *  @param mapper The mapper that processes the source value before this mapper.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLFrom(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that maps strings to URLs.
 *
 *  @param allowedSchemes The set of allowed schemes for this mapper to accept.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURL(NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that maps strings to URLs.
 *
 *  @param mapper The mapper that processes the source value before this mapper.
 *  @param allowedSchemes The set of allowed schemes for this mapper to accept.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLFrom(id<HYDMapper> mapper, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(1,2);

#pragma mark - Pending Deprecation

/*! Constructs a mapper that maps strings to URLs.
 *
 *  @param allowedSchemes The set of allowed schemes for this mapper to accept.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLOfScheme(NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that maps strings to URLs.
 *
 *  @param mapper The mapper that processes the source value before this mapper.
 *  @param allowedSchemes The set of allowed schemes for this mapper to accept.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToURLOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)
HYD_REQUIRE_NON_NIL(2);
