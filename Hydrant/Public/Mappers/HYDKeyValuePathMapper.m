#import "HYDKeyValuePathMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDError.h"
#import "HYDObjectFactory.h"
#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import "HYDFunctions.h"
#import "HYDWalker.h"


@interface HYDKeyValuePathMapper () <HYDWalkerDelegate>

@property (strong, nonatomic) HYDWalker *walker;

@end


@implementation HYDKeyValuePathMapper

- (id)initWithDestinationKey:(NSString *)destinationKey fromClass:(Class)sourceClass toClass:(Class)destinationClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.walker = [[HYDWalker alloc] initWithDestinationKey:destinationKey
                                                    sourceClass:sourceClass
                                               destinationClass:destinationClass
                                                        mapping:mapping
                                                        factory:[[HYDObjectFactory alloc] init]
                                                       delegate:self];
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    return [self.walker objectFromSourceObject:sourceObject error:error];
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[[self class] alloc] initWithDestinationKey:destinationKey
                                              fromClass:self.walker.destinationClass
                                                toClass:self.walker.sourceClass
                                                mapping:[self.walker inverseMapping]];
}

- (NSString *)destinationKey
{
    return [self.walker destinationKey];
}

#pragma mark - <HYDWalker>

- (BOOL)walker:(HYDWalker *)walker shouldReadKey:(NSString *)keyPath onObject:(id)target
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

- (id)walker:(HYDWalker *)walker valueForKey:(NSString *)keyPath onObject:(id)target
{
    return [target valueForKeyPath:keyPath];
}

- (void)walker:(HYDWalker *)walker setValue:(id)value forKey:(NSString *)keyPath onObject:(id)target
{
    if (!value) {
        return;
    }

    NSMutableArray *keyComponents = [[keyPath componentsSeparatedByString:@"."] mutableCopy];
    NSString *keyToMutate = keyComponents.lastObject;
    [keyComponents removeLastObject];

    id keyTarget = target;
    for (NSString *key in keyComponents) {
        if (![self hasKey:key onObject:keyTarget]) {
            id intermediateObject = [walker.factory newObjectOfClass:self.walker.destinationClass];
            [keyTarget setValue:intermediateObject forKey:key];
        }
        keyTarget = [keyTarget valueForKey:key];
    }

    [keyTarget setValue:value forKey:keyToMutate];
}

#pragma mark - Private

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

@end


HYD_EXTERN
HYDKeyValuePathMapper *HYDMapObjectPath(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return [[HYDKeyValuePathMapper alloc] initWithDestinationKey:destinationKey
                                                       fromClass:sourceClass
                                                         toClass:destinationClass
                                                         mapping:mapping];
}
