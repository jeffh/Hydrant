#import "HYDBase.h"

@protocol HYDMapper;

/*! Constructs a mapper that converts strings to numbers.
 *
 *  @params destinationKey The property hint to where the place the mapped value to for other mappers.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(NSString *destinationKey);

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
id<HYDMapper> HYDMapStringToNumber(NSString *destinationKey, NSNumberFormatterStyle numberFormatterStyle);

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
id<HYDMapper> HYDMapStringToNumber(NSString *destinationKey, NSNumberFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);

/*! Constructs a mapper that converts strings to numbers.
 *
 *  @params mapper The mapper that processes the source value before this mapper.
 *  @params NSNumberFormatter A custom number formatter instance to use.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);
