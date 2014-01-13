#import "JKSEnumMapper.h"
#import "JKSError.h"

@interface JKSEnumMapper ()
@property (strong, nonatomic) NSDictionary *mapping;
@end

@implementation JKSEnumMapper

#pragma mark - <JKSMapper>

- (id)initWithDestinationKey:(NSString *)destinationKey mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.mapping = mapping;
    }
    return self;
}

- (id)objectFromSourceObject:(id)sourceObject error:(NSError *__autoreleasing *)error
{
    id result = self.mapping[sourceObject];
    if (!result) {
        *error = [JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectValue
                                   sourceObject:sourceObject
                                       byMapper:self];
    }
    return result;
}

- (id)objectFromSourceObject:(id)srcObject toClass:(Class)dstClass error:(NSError *__autoreleasing *)error
{
    return [self objectFromSourceObject:srcObject error:error];
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
}

- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    NSMutableDictionary *reverseMapping = [[NSMutableDictionary alloc] initWithCapacity:self.mapping.count];
    for (id key in self.mapping) {
        id value = self.mapping[key];
        reverseMapping[value] = key;
    }
    return [[JKSEnumMapper alloc] initWithDestinationKey:destinationKey mapping:reverseMapping];
}

@end

JKS_EXTERN
JKSEnumMapper* JKSEnum(NSString *dstKey, NSDictionary *mapping)
{
    return [[JKSEnumMapper alloc] initWithDestinationKey:dstKey mapping:mapping];
}