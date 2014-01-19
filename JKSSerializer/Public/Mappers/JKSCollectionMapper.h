#import "JKSMapper.h"
#import "JKSBase.h"

@interface JKSCollectionMapper : NSObject <JKSMapper>

- (id)initWithItemMapper:(id<JKSMapper>)wrappedMapper sourceCollectionClass:(Class)sourceCollectionClass destinationCollectionClass:(Class)destinationCollectionClass;

@end

JKS_EXTERN
JKSCollectionMapper * JKSArrayOf(id<JKSMapper> itemMapper);

JKS_EXTERN
JKSCollectionMapper * JKSSetOf(id<JKSMapper> itemMapper);