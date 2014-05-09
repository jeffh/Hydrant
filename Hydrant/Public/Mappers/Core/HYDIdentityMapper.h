#import "HYDBase.h"
#import "HYDMapper.h"


/*! A mapper that returns the source object it was given as its resulting object.
 *
 *  @see HYDObjectMapper
 */
HYD_EXTERN
id<HYDMapper> HYDMapIdentity(void);
