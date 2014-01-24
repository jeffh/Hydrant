#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDCollectionMapper : NSObject <HYDMapper>

@property (strong, nonatomic) id<HYDFactory> factory;

- (id)initWithItemMapper:(id<HYDMapper>)wrappedMapper sourceCollectionClass:(Class)sourceCollectionClass destinationCollectionClass:(Class)destinationCollectionClass;

@end


HYD_EXTERN
HYDCollectionMapper *HYDMapArrayOf(id<HYDMapper> itemMapper)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN
HYDCollectionMapper *HYDMapSetOf(id<HYDMapper> itemMapper)
HYD_REQUIRE_NON_NIL(1);