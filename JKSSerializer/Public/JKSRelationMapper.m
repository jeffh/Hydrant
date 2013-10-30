#import "JKSRelationMapper.h"
#import "JKSSerializerProtocol.h"

@interface JKSRelationMapper ()
@property (strong, nonatomic) Class srcClass;
@property (strong, nonatomic) Class dstClass;
@end

@implementation JKSRelationMapper

- (id)initWithDestinationKey:(NSString *)dstKey sourceClass:(Class)srcClass destinationClass:(Class)dstClass
{
    self = [super init];
    if (self) {
        self.srcClass = srcClass;
        self.dstClass = dstClass;
        self.destinationKey = dstKey;
    }
    return self;
}

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)sourceObject serializer:(id<JKSSerializer>)serializer
{
    if (!sourceObject) {
        return nil;
    }
    return [serializer objectOfClass:self.dstClass
                          fromObject:sourceObject];
}

- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[[self class] alloc] initWithDestinationKey:destinationKey
                                            sourceClass:self.dstClass
                                       destinationClass:self.srcClass];
}

@end

JKS_EXTERN
JKSRelationMapper* JKSRelation(NSString *dstKey, Class srcClass, Class dstClass)
{
    return [[JKSRelationMapper alloc] initWithDestinationKey:dstKey sourceClass:srcClass destinationClass:dstClass];
}

JKS_EXTERN
JKSRelationMapper* JKSDictionaryRelation(NSString *dstKey, Class srcClass)
{
    return JKSRelation(dstKey, srcClass, [NSDictionary class]);
}
