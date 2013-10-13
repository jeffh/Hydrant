#import "JKSSerializer.h"
#import <objc/runtime.h>


@interface JKSSerialization : NSObject
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;
@property (strong, nonatomic) NSDictionary *mapping;
@end

@implementation JKSSerialization

- (id)initWithSourceClass:(Class)srcClass destinationClass:(Class)dstClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.sourceClass = srcClass;
        self.destinationClass = dstClass;
        self.mapping = mapping;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p %@ -> %@> %@",
            NSStringFromClass([self class]), self, self.sourceClass, self.destinationClass, self.mapping];
}

@end


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
    id result = [self objectOfClass:serialization.destinationClass];

    if ([result conformsToProtocol:@protocol(NSMutableCopying)]) {
        result = [result mutableCopy];
    }

    for (NSString *sourceKeyPath in serialization.mapping) {
        id destinationInfo = serialization.mapping[sourceKeyPath];
        id sourceValue = [self nilIfNullObject:[sourceObject valueForKeyPath:sourceKeyPath]];

        NSString *destinationKeyPath = nil;
        id destinationValue = nil;

        if ([destinationInfo isKindOfClass:[NSArray class]]) { // @[destinationKeyPath(, containerClass), srcClass, destClass]
            Class srcClass = destinationInfo[1];
            Class destClass = [destinationInfo lastObject];
            Class containerClass = nil;
            if ([destinationInfo count] == 4) {
                srcClass = destinationInfo[2];
                containerClass = destinationInfo[1];
            }

            if (containerClass) {
                id collection = [self objectOfClass:containerClass];

                NSUInteger index = 0;
                for (id item in sourceValue) {
                    [collection insertObject:[self objectOfClass:destClass fromObject:item]
                                     atIndex:index++];
                }
                destinationValue = sourceValue ? collection : self.nullObject;
            } else if (sourceValue && sourceValue != [NSNull null]) {
                destinationValue = [self objectOfClass:destClass fromObject:sourceValue];
            }

            destinationKeyPath = destinationInfo[0];
        } else {
            destinationKeyPath = destinationInfo;
            destinationValue = sourceValue;
        }

        if (!destinationValue) {
            destinationValue = self.nullObject;
        }

        NSArray *keyPaths = [destinationKeyPath componentsSeparatedByString:@"."];
        NSMutableString *currentKeyPath = [NSMutableString new];
        for (NSString *path in keyPaths) {
            if (currentKeyPath.length) {
                [currentKeyPath appendString:@"."];
            }
            [currentKeyPath appendString:path];

            if (![result valueForKeyPath:currentKeyPath]) {
                [result setValue:[self objectOfClass:serialization.destinationClass] forKeyPath:currentKeyPath];
            }
        }
        [result setValue:destinationValue forKeyPath:destinationKeyPath];
    }
    return result;
}

- (id)objectOfClass:(Class)class
{
    id result = [class new];
    if ([result conformsToProtocol:@protocol(NSMutableCopying)]) {
        result = [result mutableCopy];
    }
    return result;
}

- (id)nilIfNullObject:(id)object
{
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}


@end
