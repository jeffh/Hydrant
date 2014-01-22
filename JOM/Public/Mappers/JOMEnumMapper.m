#import "JOMEnumMapper.h"
#import "JOMError.h"

@interface JOMEnumMapper ()
@property (strong, nonatomic) NSDictionary *mapping;
@end

@implementation JOMEnumMapper

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

#pragma mark - <JOMMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JOMError **)error
{
    id result = self.mapping[sourceObject];
    if (!result) {
        *error = [JOMError errorWithCode:JOMErrorInvalidSourceObjectValue
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:YES
                        underlyingErrors:nil];
        return nil;
    }
    return result;
}

- (void)setupAsChildMapperWithMapper:(id<JOMMapper>)mapper factory:(id<JOMFactory>)factory
{
}

- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    NSMutableDictionary *reverseMapping = [[NSMutableDictionary alloc] initWithCapacity:self.mapping.count];
    for (id key in self.mapping) {
        id value = self.mapping[key];
        reverseMapping[value] = key;
    }
    return [[JOMEnumMapper alloc] initWithDestinationKey:destinationKey mapping:reverseMapping];
}

@end

JOM_EXTERN
JOMEnumMapper *JOMEnum(NSString *dstKey, NSDictionary *mapping)
{
    return [[JOMEnumMapper alloc] initWithDestinationKey:dstKey mapping:mapping];
}