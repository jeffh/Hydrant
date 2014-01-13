#import "JKSKVCMapper.h"
#import <objc/runtime.h>
#import "JKSSerialization.h"
#import "JKSObjectFactory.h"

@interface JKSKVCMapper ()
@property (strong, nonatomic) NSMutableArray *classMapping;
@property (strong, nonatomic) id<JKSFactory> factory;
@end

@implementation JKSKVCMapper

- (id)init
{
    self = [super init];
    if (self) {
        self.classMapping = [NSMutableArray array];
        self.factory = [[JKSObjectFactory alloc] init];
    }
    return self;
}

- (void)serializeBetweenClass:(Class)srcClass andClass:(Class)dstClass withMapping:(NSDictionary *)mapping
{
    [self serializeClass:srcClass toClass:dstClass withMapping:mapping];
    NSMutableDictionary *reverseMapping = [NSMutableDictionary new];
    for (id key in mapping) {
        id value = mapping[key];
        if ([value conformsToProtocol:@protocol(JKSMapper)]) {
            id<JKSMapper> mapper = value;
            NSString *srcKey = [mapper destinationKey];
            reverseMapping[srcKey] = [mapper reverseMapperWithDestinationKey:key];
        } else {
            reverseMapping[value] = key;
        }
    }
    [self serializeClass:dstClass toClass:srcClass withMapping:reverseMapping];
}

- (void)serializeClass:(Class)srcClass toClass:(Class)dstClass withMapping:(NSDictionary *)mapping
{
    JKSSerialization *serialization = [[JKSSerialization alloc] initWithSourceClass:srcClass
                                                                   destinationClass:dstClass
                                                                            mapping:mapping];
    [self.classMapping addObject:serialization];
}

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)srcObject error:(NSError *__autoreleasing *)error
{
    return [self objectFromSourceObject:srcObject toClass:nil error:error];
}

- (id)objectFromSourceObject:(id)srcObject toClass:(Class)dstClass error:(NSError *__autoreleasing *)error {
    JKSSerialization *theSerialization = nil;
    for (JKSSerialization *serialization in self.classMapping) {
        if ([serialization canDeserializeObject:srcObject withClassHint:(Class)dstClass]){
            theSerialization = serialization;
            break;
        }
    }

    if (!theSerialization) {
        [NSException raise:@"JKSSerializerMissingMapping"
                    format:@"JKSKVCMapper does not know how to map %@ to %@", [srcObject class], dstClass ? dstClass : @"(Unknown Class)"];
    }

    return [self destinationObjectFromSourceObject:srcObject withSerialization:theSerialization error:error];
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{

}

- (NSString *)destinationKey
{
    return nil;
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return nil;
}

#pragma mark - Private

- (id)destinationObjectFromSourceObject:(id)sourceObject withSerialization:(JKSSerialization *)serialization error:(NSError *__autoreleasing *)error
{
    id destinationObject = [self newObjectOfClass:serialization.destinationClass];

    for (NSString *sourceKeyPath in serialization.mapping) {
        id destinationInfo = serialization.mapping[sourceKeyPath];
        id sourceValue = [self returnObject:nil ifObjectIsNull:[sourceObject valueForKeyPath:sourceKeyPath]];

        NSString *destinationKeyPath = destinationInfo;
        id destinationValue = sourceValue;

        if ([destinationInfo conformsToProtocol:@protocol(JKSMapper)]) {
            id<JKSMapper> mapper = destinationInfo;
            [mapper setupAsChildMapperWithMapper:self factory:self.factory];
            destinationValue = [mapper objectFromSourceObject:sourceValue error:error];
            destinationKeyPath = [mapper destinationKey];
        }

        destinationValue = [self returnObject:self.nullObject ifObjectIsNull:destinationValue];

        [self setValue:destinationValue
            forKeyPath:destinationKeyPath
             forObject:destinationObject
        objectsOfClass:serialization.destinationClass];
    }
    return destinationObject;
}

- (id)collectionOfClass:(Class)collectionClass withItemsOfClass:(Class)itemClass fromCollection:(id)sourceCollection error:(NSError *__autoreleasing *)error
{
    if (!sourceCollection) {
        return self.nullObject;
    }

    id collection = [self newObjectOfClass:collectionClass];

    NSUInteger index = 0;
    for (id item in sourceCollection) {
        [collection insertObject:[self objectFromSourceObject:item toClass:itemClass error:error]
                         atIndex:index++];
    }
    return collection;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath forObject:(id)object objectsOfClass:(Class)aClass
{
    NSArray *keyPaths = [keyPath componentsSeparatedByString:@"."];
    NSMutableString *currentKeyPath = [NSMutableString new];
    for (NSString *path in keyPaths) {
        if (currentKeyPath.length) {
            [currentKeyPath appendString:@"."];
        }
        [currentKeyPath appendString:path];

        if (![object valueForKeyPath:currentKeyPath]) {
            [object setValue:[self newObjectOfClass:aClass]
                  forKeyPath:currentKeyPath];
        }
    }
    [object setValue:value forKeyPath:keyPath];
}

- (id)newObjectOfClass:(Class)class
{
    id result = [class new];
    if ([result conformsToProtocol:@protocol(NSMutableCopying)]) {
        result = [result mutableCopy];
    }
    return result;
}

- (id)returnObject:(id)nilObject ifObjectIsNull:(id)object
{
    if (!object || object == [NSNull null]) {
        return nilObject;
    }
    return object;
}


@end
