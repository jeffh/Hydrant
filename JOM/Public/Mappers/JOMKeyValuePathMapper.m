#import "JOMKeyValuePathMapper.h"
#import "JOMIdentityMapper.h"
#import "JOMError.h"
#import "JOMObjectFactory.h"
#import "JOMClassInspector.h"
#import "JOMProperty.h"


@interface JOMKeyValuePathMapper ()
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;
@property (strong, nonatomic) NSDictionary *mapping;
@property (strong, nonatomic) id<JOMFactory> factory;
@property (weak, nonatomic) id<JOMMapper> rootMapper;
@end

@implementation JOMKeyValuePathMapper

- (id)initWithDestinationKey:(NSString *)destinationKey fromClass:(Class)sourceClass toClass:(Class)destinationClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.mapping = mapping;
        self.factory = [[JOMObjectFactory alloc] init];
        self.rootMapper = self;
        // TODO: move to class method?
        [self normalizeMapping];
    }
    return self;
}

- (void)normalizeMapping
{
    NSMutableDictionary *normalizedMapping = [NSMutableDictionary dictionaryWithCapacity:self.mapping.count];
    for (id key in self.mapping) {
        id value = self.mapping[key];
        if ([value conformsToProtocol:@protocol(JOMMapper)]) {
            normalizedMapping[key] = value;
        } else if ([value isKindOfClass:[NSString class]]) {
            normalizedMapping[key] = [[JOMIdentityMapper alloc] initWithDestinationKey:value];
        }
    }
    self.mapping = [normalizedMapping copy];
}

#pragma mark - <JOMMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JOMError **)error
{
    if (!sourceObject) {
        *error = nil;
        return nil;
    }

    for (id<JOMMapper> childMapper in self.mapping.allValues) {
        [childMapper setupAsChildMapperWithMapper:self.rootMapper factory:self.factory];
    }

    NSMutableArray *errors = [NSMutableArray array];
    BOOL hasFatalError = NO;

    id destinationObject = [self.factory newObjectOfClass:self.destinationClass];
    for (NSString *sourceKey in self.mapping) {
        id<JOMMapper> mapper = self.mapping[sourceKey];
        JOMError *innerError = nil;

        if (![self hasKeyPath:sourceKey onObject:sourceObject]) {
            innerError = [JOMError errorWithCode:JOMErrorInvalidSourceObjectType
                                    sourceObject:nil
                                       sourceKey:sourceKey
                               destinationObject:nil
                                  destinationKey:[mapper destinationKey]
                                         isFatal:YES
                                underlyingErrors:nil];
            hasFatalError = YES;
            [errors addObject:innerError];
            continue;
        }
        id sourceValue = [sourceObject valueForKeyPath:sourceKey];
        id destinationValue = [mapper objectFromSourceObject:sourceValue error:error];

        if (innerError) {
            hasFatalError = hasFatalError || [innerError isFatal];
            [errors addObject:[JOMError errorFromError:innerError
                                   prependingSourceKey:sourceKey
                                     andDestinationKey:nil
                               replacementSourceObject:sourceValue
                                               isFatal:innerError.isFatal]];
            continue;
        }

        [self recursivelySetValue:destinationValue
                       forKeyPath:mapper.destinationKey
                         onObject:destinationObject];
    }

    if (errors.count) {
        *error = [JOMError errorWithCode:JOMErrorMultipleErrors
                            sourceObject:sourceObject
                               sourceKey:nil
                       destinationObject:nil
                          destinationKey:self.destinationKey
                                 isFatal:hasFatalError
                        underlyingErrors:errors];
    }
    if (hasFatalError) {
        return nil;
    }


    return destinationObject;
}

- (void)setupAsChildMapperWithMapper:(id<JOMMapper>)mapper factory:(id<JOMFactory>)factory
{
    self.rootMapper = mapper;
    self.factory = factory;
}

- (id<JOMMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    NSMutableDictionary *invertedMapping = [NSMutableDictionary dictionaryWithCapacity:self.mapping.count];
    for (NSString *sourceKey in self.mapping) {
        id<JOMMapper> mapper = self.mapping[sourceKey];

        invertedMapping[mapper.destinationKey] = [mapper reverseMapperWithDestinationKey:sourceKey];
    }
    return [[JOMKeyValuePathMapper alloc] initWithDestinationKey:destinationKey
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

    JOMClassInspector *inspector = [JOMClassInspector inspectorForClass:[target class]];
    for (JOMProperty *property in inspector.allProperties) {
        if ([property.name isEqual:key]) {
            return YES;
        }
    }
    return NO;
}

- (void)recursivelySetValue:(id)value forKeyPath:(NSString *)keyPath onObject:(id)object
{
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

@end


JOM_EXTERN
JOMKeyValuePathMapper *JOMMapObjectPath(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    JOMKeyValuePathMapper *mapper = [[JOMKeyValuePathMapper alloc] initWithDestinationKey:destinationKey
                                                                                fromClass:sourceClass
                                                                                  toClass:destinationClass
                                                                                  mapping:mapping];
    [mapper normalizeMapping];
    return mapper;
}