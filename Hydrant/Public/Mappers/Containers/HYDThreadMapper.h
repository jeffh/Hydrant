#import "HYDBase.h"
#import "HYDMapper.h"


HYD_EXTERN
id<HYDMapper> HYDMapThreadMappersInArray(NSArray *mappers);

#define HYDMapThread(...) (HYDMapThreadMappersInArray(@[ __VA_ARGS__ ]))
