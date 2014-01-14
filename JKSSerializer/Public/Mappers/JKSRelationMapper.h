#import "JKSMapper.h"
#import "JKSBase.h"

@interface JKSRelationMapper : NSObject <JKSMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)dstKey sourceClass:(Class)srcClass destinationClass:(Class)dstClass;

@end

JKS_EXTERN
JKSRelationMapper* JKSRelation(NSString *dstKey, Class srcClass, Class dstClass);

JKS_EXTERN
JKSRelationMapper* JKSDictionaryRelation(NSString *dstKey, Class srcClass);
