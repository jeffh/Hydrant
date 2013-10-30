#import "JKSSerializerProtocol.h"
#import "JKSMapper.h"
#import "JKSCollectionMapper.h"
#import "JKSRelationMapper.h"

@interface JKSSerializer : NSObject <JKSSerializer>

@property (strong, nonatomic) id nullObject;

- (id)init;

- (void)serializeClass:(Class)srcClass toClass:(Class)dstClass withMapping:(NSDictionary *)mapping;
- (void)serializeBetweenClass:(Class)srcClass andClass:(Class)dstClass withMapping:(NSDictionary *)mapping;

- (id)objectFromObject:(id)srcObject;
- (id)objectOfClass:(Class)dstClass fromObject:(id)srcObject;

@end