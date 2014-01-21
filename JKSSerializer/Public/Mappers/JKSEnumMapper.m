#import "JKSEnumMapper.h"
#import "JKSError.h"

@interface JKSEnumMapper ()
@property (strong, nonatomic) NSDictionary *mapping;
@end

@implementation JKSEnumMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.mapping = mapping;
    }
    return self;
}

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JKSError **)error
{
    id result = self.mapping[sourceObject];
    if (!result) {
        *error = [JKSError errorWithCode:JKSErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                                byMapper:self];
        return nil;
    }
    return result;
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