#import "JKSSerializer.h"
#import <objc/runtime.h>
#import "JKSSerialization.h"
#import "JKSMapper.h"

@interface JKSSerializer ()
@property (strong, nonatomic) NSMutableArray *classMapping;
@end

@implementation JKSSerializer

+ (instancetype)sharedInstance
{
    static JKSSerializer *serializer__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serializer__ = [[self alloc] init];
    });
    return serializer__;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.classMapping = [NSMutableArray new];
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

- (id)objectFromObject:(id)srcObject
{
    return [self objectOfClass:nil fromObject:srcObject];
}

- (id)objectOfClass:(Class)dstClass fromObject:(id)srcObject
{
    JKSSerialization *theSerialization = nil;
    for (JKSSerialization *serialization in self.classMapping) {
        if ([serialization canDeserializeObject:srcObject withClassHint:(Class)dstClass]){
            theSerialization = serialization;
            break;
        }
    }

    if (!theSerialization) {
        [NSException raise:@"JKSSerializerMissingMapping"
                    format:@"JKSSerializer does not know how to map %@ to %@", [srcObject class], dstClass ? dstClass : @"(Unknown Class)"];
    }

    return [self destinationObjectFromSourceObject:srcObject withSerialization:theSerialization];
}

#pragma mark - Private

- (id)destinationObjectFromSourceObject:(id)sourceObject withSerialization:(JKSSerialization *)serialization
{
    id destinationObject = [self newObjectOfClass:serialization.destinationClass];

    for (NSString *sourceKeyPath in serialization.mapping) {
        id destinationInfo = serialization.mapping[sourceKeyPath];
        id sourceValue = [self returnObject:nil ifObjectIsNull:[sourceObject valueForKeyPath:sourceKeyPath]];

        NSString *destinationKeyPath = destinationInfo;
        id destinationValue = sourceValue;

        if ([destinationInfo conformsToProtocol:@protocol(JKSMapper)]) {
            id<JKSMapper> mapper = destinationInfo;
            destinationValue = [mapper objectFromSourceObject:sourceValue serializer:self];
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

- (id)collectionOfClass:(Class)collectionClass withItemsOfClass:(Class)itemClass fromCollection:(id)sourceCollection
{
    if (!sourceCollection) {
        return self.nullObject;
    }

    id collection = [self newObjectOfClass:collectionClass];

    NSUInteger index = 0;
    for (id item in sourceCollection) {
        [collection insertObject:[self objectOfClass:itemClass fromObject:item]
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
