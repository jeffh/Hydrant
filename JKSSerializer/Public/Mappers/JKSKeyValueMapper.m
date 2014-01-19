#import "JKSKeyValueMapper.h"
#import "JKSFactory.h"
#import "JKSObjectFactory.h"
#import "JKSError.h"
#import "JKSIdentityMapper.h"
#import "JKSClassInspector.h"
#import "JKSProperty.h"

@interface JKSKeyValueMapper ()
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;
@property (strong, nonatomic) NSDictionary *mapping;
@property (strong, nonatomic) id<JKSFactory> factory;
@property (weak, nonatomic) id<JKSMapper> rootMapper;
@end

@implementation JKSKeyValueMapper

- (id)initWithDestinationKey:(NSString *)destinationKey fromClass:(Class)sourceClass toClass:(Class)destinationClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.mapping = mapping;
        self.rootMapper = self;
        self.factory = [[JKSObjectFactory alloc] init];
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

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing NSError **)error
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

        if (![self hasKey:sourceKey onObject:sourceObject]) {
            *error = [JKSError errorWithDomain:JKSErrorDomain code:JKSErrorInvalidSourceObjectType userInfo:@{}];
            return nil;
        }

        id value = [sourceObject valueForKey:sourceKey];
        [destinationObject setValue:value
                             forKey:mapper.destinationKey];
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
    return [[JKSKeyValueMapper alloc] initWithDestinationKey:destinationKey
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

    JKSClassInspector *inspector = [JKSClassInspector inspectorForClass:[target class]];
    for (JKSProperty *property in inspector.allProperties) {
        if ([property.name isEqual:key]) {
            return YES;
        }
    }
    return NO;
}

@end

JKS_EXTERN
JKSKeyValueMapper *JKSMapKeyValuesTo(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return [[JKSKeyValueMapper alloc] initWithDestinationKey:destinationKey
                                                   fromClass:sourceClass
                                                     toClass:destinationClass
                                                     mapping:mapping];
}
