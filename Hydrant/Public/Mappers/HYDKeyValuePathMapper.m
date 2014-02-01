#import "HYDKeyValuePathMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDError.h"
#import "HYDObjectFactory.h"
#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import "HYDFunctions.h"


@interface HYDKeyValuePathMapper ()

@property (copy, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;
@property (strong, nonatomic) NSDictionary *mapping;
@property (strong, nonatomic) id<HYDFactory> factory;

@end


@implementation HYDKeyValuePathMapper

- (id)initWithDestinationKey:(NSString *)destinationKey fromClass:(Class)sourceClass toClass:(Class)destinationClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.mapping = HYDNormalizeKeyValueDictionary(mapping);
        self.factory = [[HYDObjectFactory alloc] init];
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetError(error, nil);
    if (!sourceObject) {
        return nil;
    }

    NSMutableArray *errors = [NSMutableArray array];
    BOOL hasFatalError = NO;

    id destinationObject = [self.factory newObjectOfClass:self.destinationClass];
    for (NSString *sourceKey in self.mapping) {
        id<HYDMapper> mapper = self.mapping[sourceKey];
        HYDError *innerError = nil;

        id sourceValue = nil;
        if ([self hasKeyPath:sourceKey onObject:sourceObject]) {
            sourceValue = [sourceObject valueForKeyPath:sourceKey];
        }

        id destinationValue = [mapper objectFromSourceObject:sourceValue error:&innerError];

        if (innerError) {
            hasFatalError = hasFatalError || [innerError isFatal];
            [errors addObject:[HYDError errorFromError:innerError
                                   prependingSourceKey:sourceKey
                                     andDestinationKey:nil
                               replacementSourceObject:sourceValue
                                               isFatal:innerError.isFatal]];
            continue;
        }

        if ([[NSNull null] isEqual:destinationValue] && ![self requiresNSNullForClass:self.destinationClass]) {
            destinationValue = nil;
        } else if (!destinationValue && [self requiresNSNullForClass:self.destinationClass]) {
            destinationValue = [NSNull null];
        }

        [self recursivelySetValue:destinationValue
                       forKeyPath:mapper.destinationKey
                         onObject:destinationObject];
    }

    if (errors.count) {
        HYDSetError(error, [HYDError errorWithCode:HYDErrorMultipleErrors
                                      sourceObject:sourceObject
                                         sourceKey:nil
                                 destinationObject:nil
                                    destinationKey:self.destinationKey
                                           isFatal:hasFatalError
                                  underlyingErrors:errors]);
    }

    if (hasFatalError) {
        return nil;
    }

    return destinationObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    NSMutableDictionary *invertedMapping = [NSMutableDictionary dictionaryWithCapacity:self.mapping.count];
    for (NSString *sourceKey in self.mapping) {
        id<HYDMapper> mapper = self.mapping[sourceKey];

        invertedMapping[mapper.destinationKey] = [mapper reverseMapperWithDestinationKey:sourceKey];
    }
    return [[HYDKeyValuePathMapper alloc] initWithDestinationKey:destinationKey
                                                       fromClass:self.destinationClass
                                                         toClass:self.sourceClass
                                                         mapping:invertedMapping];
}

#pragma mark - Private

- (BOOL)hasKeyPath:(NSString *)keyPath onObject:(id)target
{
    NSArray *keyComponents = [keyPath componentsSeparatedByString:@"."];
    id keyTarget = target;
    for (NSString *key in keyComponents) {
        if (![self hasKey:key onObject:keyTarget]) {
            return NO;
        }
        keyTarget = [keyTarget valueForKey:key];
    }
    return YES;
}

- (BOOL)hasKey:(NSString *)key onObject:(id)target
{
    if ([target respondsToSelector:@selector(objectForKey:)]) {
        if ([target valueForKey:key]) {
            return YES;
        }
    }

    HYDClassInspector *inspector = [HYDClassInspector inspectorForClass:[target class]];
    for (HYDProperty *property in inspector.allProperties) {
        if ([property.name isEqual:key]) {
            return YES;
        }
    }
    return NO;
}

- (void)recursivelySetValue:(id)value forKeyPath:(NSString *)keyPath onObject:(id)object
{
    if (!value) {
        return;
    }

    NSMutableArray *keyComponents = [[keyPath componentsSeparatedByString:@"."] mutableCopy];
    NSString *keyToMutate = keyComponents.lastObject;
    [keyComponents removeLastObject];

    id keyTarget = object;
    for (NSString *key in keyComponents) {
        if (![self hasKey:key onObject:keyTarget]) {
            id intermediateObject = [self.factory newObjectOfClass:self.destinationClass];
            [keyTarget setValue:intermediateObject forKey:key];
        }
        keyTarget = [keyTarget valueForKey:key];
    }

    [keyTarget setValue:value forKey:keyToMutate];
}

- (BOOL)requiresNSNullForClass:(Class)aClass
{
    NSArray *nullableClasses = @[[NSDictionary class], [NSHashTable class]];
    for (Class nullableClass in nullableClasses) {
        if ([aClass isSubclassOfClass:nullableClass]) {
            return YES;
        }
    }
    return NO;
}

@end


HYD_EXTERN
HYDKeyValuePathMapper *HYDMapObjectPath(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return [[HYDKeyValuePathMapper alloc] initWithDestinationKey:destinationKey
                                                       fromClass:sourceClass
                                                         toClass:destinationClass
                                                         mapping:mapping];
}
