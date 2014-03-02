#import "HYDBase.h"

@protocol HYDMapper;

/*! Constructs a mapper that converts strings to dates.
 *
 *  @params destinationKey The property hint to where the place the mapped value to for other mappers.
 *  @params formatString The date format string to parse the string.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(NSString *destinationKey, NSString *formatString);

/*! Constructs a mapper that converts strings to dates.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 *  @params formatString The date format string to parse the string.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(id<HYDMapper> mapper, NSString *formatString);

/*! Constructs a mapper that converts strings to dates.
 *
 *  @params destinationKey The property hint to where the place the mapped value to for other mappers.
 *  @params dateFormatter The date formatter instance to use to parse date strings.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(NSString *destinationKey, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);

/*! Constructs a mapper that converts strings to dates.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 *  @params dateFormatter The date formatter instance to use to parse date strings.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToDate(id<HYDMapper> mapper, NSDateFormatter *dateFormatter)
HYD_REQUIRE_NON_NIL(2);
