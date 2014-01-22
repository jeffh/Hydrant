#import "JOMMapper.h"
#import "JOMBase.h"

@interface JOMCollectionMapper : NSObject <JOMMapper>

- (id)initWithItemMapper:(id<JOMMapper>)wrappedMapper sourceCollectionClass:(Class)sourceCollectionClass destinationCollectionClass:(Class)destinationCollectionClass;

@end

JOM_EXTERN
JOMCollectionMapper *JOMArrayOf(id<JOMMapper> itemMapper);

JOM_EXTERN
JOMCollectionMapper *JOMSetOf(id<JOMMapper> itemMapper);