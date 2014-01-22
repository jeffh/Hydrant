#import "JOMKeyValueMapper.h"
#import "JOMFactory.h"
#import "JOMObjectFactory.h"
#import "JOMError.h"
#import "JOMIdentityMapper.h"
#import "JOMClassInspector.h"
#import "JOMProperty.h"

@interface JOMKeyValueMapper ()
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;
@property (strong, nonatomic) NSDictionary *mapping;
@property (strong, nonatomic) id<JOMFactory> factory;
@property (weak, nonatomic) id<JOMMapper> rootMapper;
@end

@implementation JOMKeyValueMapper

- (id)initWithDestinationKey:(NSString *)destinationKey fromClass:(Class)sourceClass toClass:(Class)destinationClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.mapping = mapping;
        self.rootMapper = self;
        self.factory = [[JOMObjectFactory alloc] init];
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

        if (![self hasKey:sourceKey onObject:sourceObject]) {
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

        id sourceValue = [sourceObject valueForKey:sourceKey];
        id transformedValue = [mapper objectFromSourceObject:sourceValue error:&innerError];

        if (innerError) {
            hasFatalError = hasFatalError || [innerError isFatal];
            [errors addObject:[JOMError errorFromError:innerError
                                   prependingSourceKey:sourceKey
                                     andDestinationKey:nil
                               replacementSourceObject:sourceValue
                                               isFatal:innerError.isFatal]];
            continue;
        }

        [destinationObject setValue:transformedValue
                             forKey:mapper.destinationKey];
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
    return [[JOMKeyValueMapper alloc] initWithDestinationKey:destinationKey
                                                   fromClass:self.destinationClass
                                                     toClass:self.sourceClass
                                                     mapping:invertedMapping];
}

#pragma mark - Private

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

@end

JOM_EXTERN
JOMKeyValueMapper *JOMMapObject(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return [[JOMKeyValueMapper alloc] initWithDestinationKey:destinationKey
                                                   fromClass:sourceClass
                                                     toClass:destinationClass
                                                     mapping:mapping];
}
