#import "JKSKVCMapper.h"
#import "JKSKVCRelation.h"
#import "JKSKVCField.h"

@interface JKSKVCMapper ()
@property (copy, nonatomic) NSDictionary *mapping;
@end

@implementation JKSKVCMapper

+ (instancetype)mapperWithDSLMapping:(NSDictionary *)dictionary
{
    NSMutableDictionary *mapping = [dictionary mutableCopy];
    for (NSString *key in dictionary) {
        id processorType = dictionary[key];
        if ([processorType isKindOfClass:[NSArray class]]) {
            mapping[key] = [JKSKVCRelation relationFromArray:processorType];
        } else if ([processorType isKindOfClass:[NSString class]]) {
            mapping[key] = [[JKSKVCField alloc] initWithName:dictionary[key]];
        }
    }
    return [[self alloc] initWithMapping:mapping];
}

- (id)initWithMapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.mapping = mapping;
    }
    return self;
}

- (void)serializeToObject:(id)object fromObject:(id)sourceObject serializer:(id<JKSSerializer>)serializer
{
    for (NSString *sourceKeyPath in self.mapping) {
        id<JKSProcessor> processor = self.mapping[sourceKeyPath];
        id value = [processor serializeObject:sourceObject sourceKey:sourceKeyPath serializer:serializer];
        [object setValue:value forKey:[processor destinationKey]];
    }
}

- (void)deserializeToObject:(id)object fromObject:(id)sourceObject serializer:(id<JKSSerializer>)serializer
{
    for (NSString *destinationKeyPath in self.mapping) {
        id<JKSProcessor> processor = self.mapping[destinationKeyPath];
        id value = nil;

        value = [processor deserializeObject:sourceObject serializer:serializer];

        if (![serializer isNullObject:value]) {
            [object setValue:value forKey:destinationKeyPath];
        }
    }
}

@end
