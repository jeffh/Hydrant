#import "JKSKeyValueSerializer.h"
#import <objc/runtime.h>

@interface JKSKeyValueSerializer ()
@property (strong, nonatomic) NSMutableDictionary *classToKeyPaths;
@end

@implementation JKSKeyValueSerializer

static JKSKeyValueSerializer *serializer__;

+ (instancetype)sharedSerializer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serializer__ = [self new];
    });
    return serializer__;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.classToKeyPaths = [NSMutableDictionary new];
    }
    return self;
}

- (void)registerClass:(Class)aClass withMapping:(NSDictionary *)dictionary
{
    self.classToKeyPaths[NSStringFromClass(aClass)] = dictionary;
}

- (void)serializeToObject:(id)object fromObject:(id)sourceObject nullObject:(id)nullObject
{
    NSDictionary *mapping = self.classToKeyPaths[NSStringFromClass([sourceObject class])];
    for (NSString *sourceKeyPath in mapping) {
        id value = [sourceObject valueForKey:sourceKeyPath];
        id destinationKeyPath = mapping[sourceKeyPath];

        // arrays are assumed to be in [destinationKey, inputClass, outputClass]
        if ([destinationKeyPath isKindOfClass:[NSArray class]]) {

            // if inputClass => @[inputClass]
            if (![self isObject:value aNullObject:nullObject] && [destinationKeyPath[1] isKindOfClass:[NSArray class]]) {
                NSMutableArray *collectionValue = [NSMutableArray new];
                for (id item in value) {
                    [collectionValue addObject:[self objectForSerializedObject:item
                                                                      forClass:[destinationKeyPath lastObject]
                                                                    nullObject:nullObject]];
                }
                value = collectionValue;
            } else {
                value = [self objectForSerializedObject:value forClass:[destinationKeyPath lastObject] nullObject:nullObject];
            }
            destinationKeyPath = [destinationKeyPath firstObject];
        }

        [object setValue:value forKey:destinationKeyPath];
    }
}

- (void)deserializeToObject:(id)object fromObject:(id)sourceObject nullObject:(id)nullObject
{
    NSDictionary *mapping = self.classToKeyPaths[NSStringFromClass([object class])];
    for (NSString *destinationKeyPath in mapping) {
        id sourceKeyPath = mapping[destinationKeyPath];
        id value = nil;

        // arrays are assumed to be in [destinationKey, inputClass, outputClass]
        if ([sourceKeyPath isKindOfClass:[NSArray class]]) {
            value = [sourceObject valueForKey:[sourceKeyPath firstObject]];
            id destinationClass = sourceKeyPath[1];

            // if inputClass is @[inputClass], then parse as collection
            if (![self isObject:value aNullObject:nullObject] && [destinationClass isKindOfClass:[NSArray class]]) {
                NSMutableArray *collectionValue = [NSMutableArray new];
                for (id item in value) {
                    [collectionValue addObject:[self objectForDeserializedObject:item
                                                                        forClass:destinationClass[0]
                                                                      nullObject:nullObject]];
                }
                value = collectionValue;
            } else {
                value = [self objectForDeserializedObject:value forClass:destinationClass nullObject:nullObject];
            }
        } else {
            value = [sourceObject valueForKey:sourceKeyPath];
        }

        if (![self isObject:value aNullObject:nullObject]) {
            [object setValue:value forKey:destinationKeyPath];
        }
    }
}

#pragma mark - Private

- (BOOL)isObject:(id)object aNullObject:(id)nullObject
{
    return object == nil || object == [NSNull null] || object == nullObject || [nullObject isEqual:object];
}

- (id)objectForDeserializedObject:(id)value forClass:(Class)aClass nullObject:(id)nullObject
{
    if ([self isObject:value aNullObject:nullObject]) {
        return nullObject;
    } else {
        id obj = [[aClass alloc] init];
        [self deserializeToObject:obj fromObject:value nullObject:nullObject];
        return obj;
    }
}

- (id)objectForSerializedObject:(id)value forClass:(Class)aClass nullObject:(id)nullObject
{
    if ([self isObject:value aNullObject:nullObject]) {
        return nullObject;
    } else {
        id obj = [[aClass alloc] init];
        [self serializeToObject:obj fromObject:value nullObject:nullObject];
        return obj;
    }
}


@end
