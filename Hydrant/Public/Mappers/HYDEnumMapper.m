#import "HYDEnumMapper.h"
#import "HYDError.h"

@interface HYDEnumMapper ()
@property (strong, nonatomic) NSDictionary *mapping;
@end

@implementation HYDEnumMapper

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

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    id result = self.mapping[sourceObject];
    if (!result) {
        *error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
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

- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    NSMutableDictionary *reverseMapping = [[NSMutableDictionary alloc] initWithCapacity:self.mapping.count];
    for (id key in self.mapping) {
        id value = self.mapping[key];
        reverseMapping[value] = key;
    }
    return [[HYDEnumMapper alloc] initWithDestinationKey:destinationKey mapping:reverseMapping];
}

@end

HYD_EXTERN
HYDEnumMapper *HYDEnum(NSString *dstKey, NSDictionary *mapping)
{
    return [[HYDEnumMapper alloc] initWithDestinationKey:dstKey mapping:mapping];
}