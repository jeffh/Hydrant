#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDFirstMapper : NSObject <HYDMapper>
@property (strong, nonatomic) id<HYDFactory> factory;

- (id)initWithMappers:(NSArray *)mappers;

@end


HYD_EXTERN
HYDFirstMapper *HYDFirstInMapperArray(NSArray *mappers);

#define HYDFirst(...) (HYDFirstInMapperArray(@[ __VA_ARGS__ ]))
