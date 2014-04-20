#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDDispatchMapper : NSObject <HYDMapper>

@end

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapDispatch(NSArray *mappingTuple);
