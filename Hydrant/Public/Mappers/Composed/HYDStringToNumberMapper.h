#import "HYDBase.h"

@protocol HYDMapper;

/*! Constructs a mapper that converts strings to decimal numbers.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(void);

/*! Constructs a mapper that converts strings to numbers.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(id<HYDMapper> mapper);

/*! Constructs a mapper that converts strings to numbers.
 *
 *  @params destinationKey The property hint to where the place the mapped value to for other mappers.
 *  @params numberFormatStyle the NSNumberFormatterStyle for the internal number formatter
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(NSNumberFormatterStyle numberFormatterStyle);

/*! Constructs a mapper that converts strings to numbers.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 *  @params numberFormatStyle the NSNumberFormatterStyle for the internal number formatter
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatterStyle);

/*! Constructs a mapper that converts strings to numbers.
 *
 *  @params destinationKey The property hint to where the place the mapped value to for other mappers.
 *  @params NSNumberFormatter A custom number formatter instance to use.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(NSNumberFormatter *formatter)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that converts strings to numbers.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 *  @params NSNumberFormatter A custom number formatter instance to use.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

#pragma mark - Pending Deprecation

/*! Constructs a mapper that converts strings to numbers.
 */
HYD_EXTERN
id<HYDMapper> HYDMapStringToDecimalNumber(void);
