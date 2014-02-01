#import "HYDWalker.h"
#import "HYDFactory.h"
#import "HYDFunctions.h"
#import "HYDError.h"


@interface HYDWalker ()

@property (copy, nonatomic, readwrite) NSString *destinationKey;
@property (strong, nonatomic, readwrite) Class sourceClass;
@property (strong, nonatomic, readwrite) Class destinationClass;
@property (strong, nonatomic, readwrite) NSDictionary *mapping;
@property (strong, nonatomic, readwrite) id<HYDFactory> factory;
@property (weak, nonatomic, readwrite) id<HYDWalkerDelegate> delegate;

@end


@implementation HYDWalker

- (id)initWithDestinationKey:(NSString *)destinationKey
                 sourceClass:(Class)sourceClass
            destinationClass:(Class)destinationClass
                     mapping:(NSDictionary *)mapping
                     factory:(id<HYDFactory>)factory
                    delegate:(id<HYDWalkerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.mapping = HYDNormalizeKeyValueDictionary(mapping);
        self.factory = factory;
        self.delegate = delegate;
    }
    return self;
}

- (NSDictionary *)inverseMapping
{
    NSMutableDictionary *invertedMapping = [NSMutableDictionary dictionaryWithCapacity:self.mapping.count];
    for (NSString *sourceKey in self.mapping) {
        id<HYDMapper> mapper = self.mapping[sourceKey];

        invertedMapping[mapper.destinationKey] = [mapper reverseMapperWithDestinationKey:sourceKey];
    }
    return invertedMapping;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetError(error, nil);
    if (!sourceObject) {
        *error = nil;
        return nil;
    }

    NSMutableArray *errors = [NSMutableArray array];
    BOOL hasFatalError = NO;

    id destinationObject = [self.factory newObjectOfClass:self.destinationClass];
    for (NSString *sourceKey in self.mapping) {
        id<HYDMapper> mapper = self.mapping[sourceKey];
        HYDError *innerError = nil;

        id sourceValue = nil;
        if ([self.delegate walker:self shouldReadKey:sourceKey onObject:sourceObject]) {
            sourceValue = [self.delegate walker:self valueForKey:sourceKey onObject:sourceObject];
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
        }

        [self.delegate walker:self setValue:destinationValue forKey:mapper.destinationKey onObject:destinationObject];
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
    return [[[self class] alloc] initWithDestinationKey:destinationKey
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
