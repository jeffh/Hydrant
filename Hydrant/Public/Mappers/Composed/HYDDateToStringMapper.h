#import "HYDBase.h"

@protocol HYDMapper;

/*! Constructs a mapper that converts dates to strings.
 *
 *  @param formatString The date format string to emit the string.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(NSString *formatString);

/*! Constructs a mapper that converts dates to strings.
 *
 *  @param mapper The mapper that processes the source value before this mapper.
 *  @param formatString The date format string to emit the string.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(id<HYDMapper> mapper, NSString *formatString);

/*! Constructs a mapper that converts dates to strings.
 *
 *  @param dateFormatter The date formatter instance to use to emit date strings.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that converts dates to strings.
 *
 *  @param mapper The mapper that processes the source value before this mapper.
 *  @param dateFormatter The date formatter instance to use to emit date strings.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDateToString(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);
