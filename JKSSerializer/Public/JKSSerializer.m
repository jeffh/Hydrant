#import "JKSSerializer.h"
#import <objc/runtime.h>
#import "JKSSerialization.h"

@interface JKSSerializer ()
@property (strong, nonatomic) NSMutableArray *classMapping;
@end

@implementation JKSSerializer

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
        if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *classMapping = [[value subarrayWithRange:NSMakeRange(1, [value count] - 1)] mutableCopy];

            id tmp = classMapping[classMapping.count - 2];
            classMapping[classMapping.count - 2] = classMapping.lastObject;
            classMapping[classMapping.count - 1] = tmp;

            reverseMapping[[value firstObject]] = [@[key] arrayByAddingObjectsFromArray:classMapping];
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
        if ((!dstClass || serialization.destinationClass == dstClass) && [srcObject isKindOfClass:serialization.sourceClass]) {
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
    id destinationObject = [self objectOfClass:serialization.destinationClass];

    for (NSString *sourceKeyPath in serialization.mapping) {
        id destinationInfo = serialization.mapping[sourceKeyPath];
        id sourceValue = [self returnObject:nil ifObjectIsNull:[sourceObject valueForKeyPath:sourceKeyPath]];

        NSString *destinationKeyPath = destinationInfo;
        id destinationValue = sourceValue;

        if ([destinationInfo isKindOfClass:[NSArray class]]) {
            Class destClass = [destinationInfo lastObject];
            destinationKeyPath = destinationInfo[0];

            NSAssert([destinationInfo count] == 3 || [destinationInfo count] == 4,
                     @"Arrays in serialization mapping can only be 3 or 4 elements:"
                     @" in @[destinationKeyPath(, collectionClass), sourceClass, destinationClass]"
                     @" form.");

            if ([destinationInfo count] == 4) {
                destinationValue = [self collectionOfClass:destinationInfo[1]
                                          withItemsOfClass:destClass
                                            fromCollection:sourceValue];
            } else if (sourceValue && sourceValue != [NSNull null]) {
                destinationValue = [self objectOfClass:destClass fromObject:sourceValue];
            }
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

    id collection = [self objectOfClass:collectionClass];

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
            [object setValue:[self objectOfClass:aClass] forKeyPath:currentKeyPath];
        }
    }
    [object setValue:value forKeyPath:keyPath];
}

- (id)objectOfClass:(Class)class
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
