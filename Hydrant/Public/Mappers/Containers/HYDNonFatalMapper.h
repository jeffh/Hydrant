#import "HYDBase.h"
#import "HYDMapper.h"


@class HYDObjectFactory;

typedef id(^HYDValueBlock)();


@interface HYDNonFatalMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper defaultValue:(HYDValueBlock)defaultValue reverseDefaultValue:(HYDValueBlock)reverseDefaultValue;

@end


/*! Constructs a mapper that converts all fatal errors to non fatal errors from the given mapper.
 *
 *  @param mapper The mapper which fatal errors are converted.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNonFatally(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that converts all fatal errors to non fatal errors from the given mapper.
 *
 *  @param mapper The mapper which fatal errors are converted.
 *  @param defaultValue The default value to return when a fatal error is recieved.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNonFatallyWithDefault(id<HYDMapper> mapper, id defaultValue)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that converts all fatal errors to non fatal errors from the given mapper.
 *
 *  @param mapper The mapper which fatal errors are converted.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNonFatallyWithDefault(id<HYDMapper> mapper, id defaultValue, id reversedDefault)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that converts all fatal errors to non fatal errors from the given mapper.
 *
 *  @param mapper The mapper which fatal errors are converted.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNonFatallyWithDefaultFactory(id<HYDMapper> mapper, HYDValueBlock defaultValueFactory)
HYD_REQUIRE_NON_NIL(1,2);

/*! Constructs a mapper that converts all fatal errors to non fatal errors from the given mapper.
 *
 *  @param mapper The mapper which fatal errors are converted.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapNonFatallyWithDefaultFactory(id<HYDMapper> mapper, HYDValueBlock defaultValueFactory, HYDValueBlock reversedDefaultFactory)
HYD_REQUIRE_NON_NIL(1,2,3);
