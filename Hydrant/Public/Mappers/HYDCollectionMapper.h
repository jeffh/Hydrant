#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDCollectionMapper : NSObject <HYDMapper>

@property (strong, nonatomic) id<HYDFactory> factory;

- (id)initWithItemMapper:(id<HYDMapper>)wrappedMapper sourceCollectionClass:(Class)sourceCollectionClass destinationCollectionClass:(Class)destinationCollectionClass;

@end


HYD_EXTERN
HYDCollectionMapper *HYDArrayOf(id<HYDMapper> itemMapper);

HYD_EXTERN
HYDCollectionMapper *HYDSetOf(id<HYDMapper> itemMapper);