#import "HYDBase.h"


@protocol HYDMapper;


/*! Constructs a mapper to convert any object into an NSString type.
 *
 *  The implementation of this mapper simply uses -[description].
 */
HYD_EXTERN
id<HYDMapper> HYDMapToString();


/*! Constructs a mapper to convert any object into an NSString type.
 *
 *  The implementation of this mapper simply uses -[description].
 *
 *  @param innerMapper The mapper that processes the incoming source object prior to
 *                     coercing to a string.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapToStringFrom(id<HYDMapper> innerMapper)
HYD_REQUIRE_NON_NIL(1);
