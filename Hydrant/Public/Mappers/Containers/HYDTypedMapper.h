#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDTypedMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper inputClasses:(NSArray *)inputClasses outputClasses:(NSArray *)outputClasses;

@end

/*! Constructs a mapper that validates the received and output values' types.
 *
 *  @param destinationKey The property hint to indicate where to store the result of this mapper.
 *  @param sourceAndDestinationClass The expected source and destination class.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapType(NSString *destinationKey, Class sourceAndDestinationClass);

/*! Constructs a mapper that validates the received and output values' types.
 *
 *  @param destinationKey The property hint to indicate where to store the result of this mapper.
 *  @param sourceClass The expected input class. An invalid input class will result a fatal error.
 *                     Passing in nil will indicate any class is valid.
 *  @param destinationClass The expected output class. An invalid input class will result a fatal error.
 *                          Passing in nil will indicate any class is valid.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapType(NSString *destinationKey, Class sourceClass, Class destinationClass);

/*! Constructs a mapper that validates the received and output values' types.
 *
 *  @param destinationKey The property hint to indicate where to store the result of this mapper.
 *  @param sourceClasses An array of expected input classes. An invalid input class will result a fatal error.
 *                       Passing in nil or an empty array will indicate any class is valid.
 *  @param destinationClasses An array of expected output classes. An invalid input class will result a fatal error.
 *                       Passing in nil or an empty array will indicate any class is valid.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapTypes(NSString *destinationKey, NSArray *sourceClasses, NSArray *destinationClasses);

/*! Constructs a mapper that validates the received and output values' types.
 *
 *  @param mapperToWrap The mapper whose source and destination objects are validated.
 *  @param sourceAndDestinationClass The expected source and destination class.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapType(id<HYDMapper> mapperToWrap, Class sourceAndDestinationClass);

/*! Constructs a mapper that validates the received and output values' types.
 *
 *  @param mapperToWrap The mapper whose source and destination objects are validated.
 *  @param sourceClass The expected input class. An invalid input class will result a fatal error.
 *                     Passing in nil will indicate any class is valid.
 *  @param destinationClass The expected output class. An invalid input class will result a fatal error.
 *                          Passing in nil will indicate any class is valid.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapType(id<HYDMapper> mapperToWrap, Class sourceClass, Class destinationClass);

/*! Constructs a mapper that validates the received and output values' types.
 *
 *  @param mapperToWrap The mapper whose source and destination objects are validated.
 *  @param sourceClasses An array of expected input classes. An invalid input class will result a fatal error.
 *                       Passing in nil or an empty array will indicate any class is valid.
 *  @param destinationClasses An array of expected output classes. An invalid input class will result a fatal error.
 *                       Passing in nil or an empty array will indicate any class is valid.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapTypes(id<HYDMapper> mapperToWrap, NSArray *sourceClasses, NSArray *destinationClasses);
