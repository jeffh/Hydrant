#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDIdentityMapper : NSObject <HYDMapper>

- (instancetype)init;

@end

/*! A mapper that returns the source object it was given as its resulting object.
 *
 *  @see HYDObjectMapper
 */
HYD_EXTERN
id<HYDMapper> HYDMapIdentity(void);
