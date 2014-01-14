#import "JKSMapper.h"
#import "JKSBase.h"

@interface JKSCollectionMapper : NSObject <JKSMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey
            fromItemsOfClass:(Class)srcClass
              toItemsOfClass:(Class)dstClass;

- (id)initWithDestinationKey:(NSString *)destinationKey
            fromItemsOfClass:(Class)srcClass
              toItemsOfClass:(Class)dstClass
       fromCollectionOfClass:(Class)srcCollectionClass
         toCollectionOfClass:(Class)dstCollectionClass;

@end


JKS_EXTERN
JKSCollectionMapper* JKSArrayOf(NSString *dstKey, Class srcClass, Class dstClass);

JKS_EXTERN
JKSCollectionMapper* JKSCollection(NSString *dstKey, Class srcCollectionClass, Class srcClass, Class dstCollectionClass, Class dstClass);
