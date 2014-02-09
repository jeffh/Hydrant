#import "HYDWalker.h"
#import "HYDFactory.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDAccessor.h"


@interface HYDWalker ()

@property (strong, nonatomic, readwrite) id<HYDAccessor> destinationAccessor;
@property (strong, nonatomic, readwrite) Class sourceClass;
@property (strong, nonatomic, readwrite) Class destinationClass;
@property (strong, nonatomic, readwrite) NSDictionary *mapping;
@property (strong, nonatomic, readwrite) id<HYDFactory> factory;
@property (weak, nonatomic, readwrite) id<HYDWalkerDelegate> delegate;

@end


@implementation HYDWalker

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
                      sourceClass:(Class)sourceClass
                 destinationClass:(Class)destinationClass
                          mapping:(NSDictionary *)mapping
                          factory:(id<HYDFactory>)factory
                         delegate:(id<HYDWalkerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.destinationAccessor = destinationAccessor;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.mapping = mapping;
        self.factory = factory;
        self.delegate = delegate;
    }
    return self;
}

- (NSDictionary *)inverseMapping
{
    NSMutableDictionary *invertedMapping = [NSMutableDictionary dictionaryWithCapacity:self.mapping.count];
    for (id<HYDAccessor> sourceAccessor in self.mapping) {
        id<HYDMapper> mapper = self.mapping[sourceAccessor];

        invertedMapping[mapper.destinationAccessor] = [mapper reverseMapperWithDestinationAccessor:sourceAccessor];
    }
    return invertedMapping;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    if (!sourceObject) {
        *error = nil;
        return nil;
    }

    NSMutableArray *errors = [NSMutableArray array];
    BOOL hasFatalError = NO;

    id destinationObject = [self.factory newObjectOfClass:self.destinationClass];
    for (id<HYDAccessor> sourceAccessor in self.mapping) {
        id<HYDMapper> mapper = self.mapping[sourceAccessor];
        HYDError *innerError = nil;

        id sourceValue = nil;
        id sourceValues = [sourceAccessor valuesFromSourceObject:sourceObject error:nil];
        if (!sourceValues) {
            continue; // TODO: handle this better?
        }

        id destinationValue = [mapper objectFromSourceObject:sourceValues[0] error:&innerError];

        if (innerError) {
            hasFatalError = hasFatalError || [innerError isFatal];
            [errors addObject:[HYDError errorFromError:innerError
                              prependingSourceAccessor:sourceAccessor
                                andDestinationAccessor:nil
                               replacementSourceObject:sourceValue
                                               isFatal:innerError.isFatal]];
        }

        if ([innerError isFatal]) {
            continue;
        }

        if (!destinationValue) {
            destinationValue = [NSNull null];
        }

        [[mapper destinationAccessor] setValues:@[destinationValue]
                                      ofClasses:@[self.destinationClass]
                                       onObject:destinationObject];
    }

    if (errors.count) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorMultipleErrors
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:self.destinationAccessor
                                                   isFatal:hasFatalError
                                          underlyingErrors:errors]);
    }

    if (hasFatalError) {
        return nil;
    }

    return destinationObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    return [[[self class] alloc] initWithDestinationAccessor:destinationAccessor
                                                 sourceClass:self.destinationClass
                                            destinationClass:self.sourceClass
                                                     mapping:[self inverseMapping]
                                                     factory:self.factory
                                                    delegate:self.delegate];

}

#pragma mark - Private

- (BOOL)requiresNSNullForClass:(Class)theClass
{
    NSArray *nullableClasses = @[[NSDictionary class], [NSHashTable class], [NSArray class], [NSOrderedSet class]];
    for (Class nullableClass in nullableClasses) {
        if ([theClass isSubclassOfClass:nullableClass]) {
            return YES;
        }
    }
    return NO;
}

@end
