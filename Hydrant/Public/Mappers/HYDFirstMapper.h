#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDFirstMapper : NSObject <HYDMapper>

- (id)initWithMappers:(NSArray *)mappers;

@end


HYD_EXTERN
HYDFirstMapper *HYDMapFirstInMapperArray(NSArray *mappers);

#define HYDMapFirst(...) (HYDMapFirstInMapperArray(@[ __VA_ARGS__ ]))
