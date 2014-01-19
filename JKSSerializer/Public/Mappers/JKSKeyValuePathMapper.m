#import "JKSKeyValuePathMapper.h"
#import "JKSIdentityMapper.h"
#import "JKSError.h"
#import "JKSObjectFactory.h"
#import "JKSClassInspector.h"
#import "JKSProperty.h"


@interface JKSKeyValuePathMapper ()
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;
@property (strong, nonatomic) NSDictionary *mapping;
@property (strong, nonatomic) id<JKSFactory> factory;
@property (weak, nonatomic) id<JKSMapper> rootMapper;
@end

@implementation JKSKeyValuePathMapper

- (id)initWithDestinationKey:(NSString *)destinationKey fromClass:(Class)sourceClass toClass:(Class)destinationClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.mapping = mapping;
        self.factory = [[JKSObjectFactory alloc] init];
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
        if ([value conformsToProtocol:@protocol(JKSMapper)]) {
            normalizedMapping[key] = value;
        } else if ([value isKindOfClass:[NSString class]]) {
            normalizedMapping[key] = JKSIdentity(value);
        }
    }
    self.mapping = [normalizedMapping copy];
}

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JKSError **)error
{
    if (!sourceObject) {
        *error = nil;
        return nil;
    }

    for (id<JKSMapper> childMapper in self.mapping.allValues) {
        [childMapper setupAsChildMapperWithMapper:self.rootMapper factory:self.factory];
    }

    id destinationObject = [self.factory newObjectOfClass:self.destinationClass];
    for (NSString *sourceKey in self.mapping) {
        id<JKSMapper> mapper = self.mapping[sourceKey];

        if (![self hasKeyPath:sourceKey onObject:sourceObject]) {
            *error = [JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectType
                                       sourceObject:sourceObject
                                           byMapper:self];
            return nil;
        }

        id value = [sourceObject valueForKeyPath:sourceKey];

        [self recursivelySetValue:value forKeyPath:mapper.destinationKey onObject:destinationObject];
    }
    return destinationObject;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
    self.rootMapper = mapper;
    self.factory = factory;
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    NSMutableDictionary *invertedMapping = [NSMutableDictionary dictionaryWithCapacity:self.mapping.count];
    for (NSString *sourceKey in self.mapping) {
        id<JKSMapper> mapper = self.mapping[sourceKey];

        invertedMapping[mapper.destinationKey] = [mapper reverseMapperWithDestinationKey:sourceKey];
    }
    return [[JKSKeyValuePathMapper alloc] initWithDestinationKey:destinationKey
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

    JKSClassInspector *inspector = [JKSClassInspector inspectorForClass:[target class]];
    for (JKSProperty *property in inspector.allProperties) {
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


JKS_EXTERN
JKSKeyValuePathMapper *JKSMapKeyValuePathsTo(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    JKSKeyValuePathMapper *mapper = [[JKSKeyValuePathMapper alloc] initWithDestinationKey:destinationKey
                                                                                fromClass:sourceClass
                                                                                  toClass:destinationClass
                                                                                  mapping:mapping];
    [mapper normalizeMapping];
    return mapper;
}