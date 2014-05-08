#import "HYDBase.h"

@protocol HYDMapper;

/*! Constructs a mapper that converts a decimal number to a string.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(void);

/*! Constructs a mapper that converts a number to a string.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that converts a number to a string.
 *
 *  @params numberFormatStyle the NSNumberFormatterStyle for the internal number formatter
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(NSNumberFormatterStyle numberFormatStyle);

/*! Constructs a mapper that converts a number to a string.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 *  @params numberFormatStyle the NSNumberFormatterStyle for the internal number formatter
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatStyle)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that converts a number to a string.
 *
 *  @params NSNumberFormatter A custom number formatter instance to use.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(NSNumberFormatter *numberFormatter)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that converts a number to a string.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 *  @params NSNumberFormatter A custom number formatter instance to use.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatter *numberFormatter)
HYD_REQUIRE_NON_NIL(1,2);

#pragma mark - Pending Deprecation

/*! Constructs a mapper that converts a number to a string.
 */
HYD_EXTERN
id<HYDMapper> HYDMapDecimalNumberToString(void);
