#import "HYDMapper.h"
#import "HYDBase.h"

@interface HYDFirstMapper : NSObject <HYDMapper>
@property (strong, nonatomic) id<HYDFactory> factory;

- (id)initWithMappers:(NSArray *)mappers;

@end

HYD_EXTERN
HYDFirstMapper *HYDFirstArray(NSArray *mappers);

#define HYDFirst(...) (HYDFirstArray(@[ __VA_ARGS__ ]))
