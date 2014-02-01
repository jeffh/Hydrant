#import "HYDKeyValueMapper.h"
#import "HYDFactory.h"
#import "HYDObjectFactory.h"
#import "HYDError.h"
#import "HYDIdentityMapper.h"
#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import "HYDFunctions.h"
#import "HYDWalker.h"


@interface HYDKeyValueMapper () <HYDWalkerDelegate>

@property (strong, nonatomic) HYDWalker *walker;

@end


@implementation HYDKeyValueMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

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

#pragma mark - <HYDWalkerDelegate>

- (BOOL)walker:(HYDWalker *)walker shouldReadKey:(NSString *)key onObject:(id)target
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

- (id)walker:(HYDWalker *)walker valueForKey:(NSString *)key onObject:(id)target
{
    return [target valueForKey:key];
}

- (void)walker:(HYDWalker *)walker setValue:(id)value forKey:(NSString *)key onObject:(id)target
{
    [target setValue:value forKey:key];
}

@end


HYD_EXTERN
HYDKeyValueMapper *HYDMapObject(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return [[HYDKeyValueMapper alloc] initWithDestinationKey:destinationKey
                                                   fromClass:sourceClass
                                                     toClass:destinationClass
                                                     mapping:mapping];
}
