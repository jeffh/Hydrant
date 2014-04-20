#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDThreadMapper : NSObject <HYDMapper>

- (instancetype)initWithMappers:(NSArray *)mappers;

@end


HYD_EXTERN
id<HYDMapper> HYDMapThreadMappersInArray(NSArray *mappers);

#define HYDMapThread(...) (HYDMapThreadMappersInArray(@[ __VA_ARGS__ ]))
