#import "HYDBase.h"
#import "HYDMapper.h"
#import "HYDConstants.h"


/*! Returns a mapper that converts NSDates to numbers.
 *  The number will be a seconds relative to a given date.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince1970(void);


/*! Returns a mapper that converts NSDates to numbers.
 *  The number will be a value relative to a given date.
 *
 *  @param unit The time unit the resulting number is in.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince1970(HYDDateTimeUnit unit);


/*! Returns a mapper that converts NSDates to numbers.
 *  The number will be seconds relative to a given date.
 *
 *  @param sinceDate The date the numeric value is relative to.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince(NSDate *sinceDate);


/*! Returns a mapper that converts NSDates to numbers.
 *  The number will be a value relative to a given date.
 *
 *  @param unit The time unit the resulting number is in.
 *  @param sinceDate The date the numeric value is relative to.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince(HYDDateTimeUnit unit, NSDate *sinceDate);


/*! Returns a mapper that converts NSDates to numbers.
 *  The number will be a seconds relative to a given date.
 *
 *  @param innerMapper The mapper that processes the source value before this mapper.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince1970(id<HYDMapper> innerMapper)
HYD_REQUIRE_NON_NIL(1);


/*! Returns a mapper that converts NSDates to numbers.
 *  The number will be a value relative to a given date.
 *
 *  @param innerMapper The mapper that processes the source value before this mapper.
 *  @param unit The time unit the resulting number is in.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince1970(id<HYDMapper> innerMapper, HYDDateTimeUnit unit)
HYD_REQUIRE_NON_NIL(1);


/*! Returns a mapper that converts NSDates to numbers.
 *  The number will be seconds relative to a given date.
 *
 *  @param innerMapper The mapper that processes the source value before this mapper.
 *  @param sinceDate The date the numeric value is relative to.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince(id<HYDMapper> innerMapper, NSDate *sinceDate)
HYD_REQUIRE_NON_NIL(1,2);


/*! Returns a mapper that converts NSDates to numbers.
 *  The number will be a value relative to a given date.
 *
 *  @param innerMapper The mapper that processes the source value before this mapper.
 *  @param unit The time unit the resulting number is in.
 *  @param sinceDate The date the numeric value is relative to.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToNumberSince(id<HYDMapper> innerMapper, HYDDateTimeUnit unit, NSDate *sinceDate)
HYD_REQUIRE_NON_NIL(1,3);
