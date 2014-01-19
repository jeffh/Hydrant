#import "JKSRelationMapper.h"

@interface JKSRelationMapper ()
@property (strong, nonatomic) Class srcClass;
@property (strong, nonatomic) Class dstClass;
@property (strong, nonatomic) id<JKSFactory> factory;
@property (weak, nonatomic) id<JKSMapper> mapper;
@end

@implementation JKSRelationMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

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

- (id)objectFromSourceObject:(id)sourceObject error:(NSError *__autoreleasing *)error
{
    if (!sourceObject) {
        return nil;
    }
    if (!self.mapper) {
        *error = [NSError errorWithDomain:NSInternalInconsistencyException
                                     code:101
                                 userInfo:@{NSLocalizedDescriptionKey: @"JKSRelationMapper cannot be used standalone"}];
        return nil;
    }
    return [self.mapper objectFromSourceObject:sourceObject error:error];
}

- (id)objectFromSourceObject:(id)srcObject toClass:(Class)dstClass error:(NSError *__autoreleasing *)error
{
    return [self objectFromSourceObject:srcObject error:error];
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
    self.mapper = mapper;
    self.factory = factory;
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
