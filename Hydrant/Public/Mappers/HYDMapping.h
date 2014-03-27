#import "HYDBase.h"
#import "HYDMapper.h"

@protocol HYDMapping <NSObject>

- (id<HYDMapper>)mapper;
- (id<HYDAccessor>)accessor;

@end

HYD_EXTERN_OVERLOADED
id<HYDMapping> HYDMap(id<HYDMapper> mapper, NSString *destinationKey);

HYD_EXTERN_OVERLOADED
id<HYDMapping> HYDMap(NSString *destinationKey, id<HYDMapper> mapper);

HYD_EXTERN_OVERLOADED
id<HYDMapping> HYDMap(id<HYDMapper> mapper, id<HYDAccessor> accessor);

HYD_EXTERN_OVERLOADED
id<HYDMapping> HYDMap(id<HYDAccessor> accessor, id<HYDMapper> mapper);
