#import "HYDKeyValueMapper.h"
#import "HYDFactory.h"
#import "HYDObjectFactory.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDKeyAccessor.h"


@interface HYDKeyValueMapper ()

@property (strong, nonatomic, readwrite) id<HYDAccessor> destinationAccessor;
@property (strong, nonatomic, readwrite) Class sourceClass;
@property (strong, nonatomic, readwrite) Class destinationClass;
@property (strong, nonatomic, readwrite) NSDictionary *mapping;
@property (strong, nonatomic, readwrite) id<HYDFactory> factory;

@end


@implementation HYDKeyValueMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor fromClass:(Class)sourceClass toClass:(Class)destinationClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.destinationAccessor = destinationAccessor;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.mapping = HYDNormalizeKeyValueDictionary(mapping, ^id(NSString *key) { return HYDAccessKey(key); });
        self.factory = [[HYDObjectFactory alloc] init];
    }
    return self;
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

        NSArray *sourceValues = [sourceAccessor valuesFromSourceObject:sourceObject error:&innerError];
        if (innerError) {
            hasFatalError = hasFatalError || [innerError isFatal];
            [errors addObject:innerError];
            continue;
        }

        BOOL isCollectionOfValues = (sourceValues.count != 1);
        id sourceValue = (isCollectionOfValues ? sourceValues : sourceValues[0]);

        id destinationValue = [mapper objectFromSourceObject:sourceValue
                                                       error:&innerError];

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
                                                 fromClass:self.destinationClass
                                                   toClass:self.sourceClass
                                                   mapping:[self inverseMapping]];

}

#pragma mark - Private

- (NSDictionary *)inverseMapping
{
    NSMutableDictionary *invertedMapping = [NSMutableDictionary dictionaryWithCapacity:self.mapping.count];
    for (id<HYDAccessor> sourceAccessor in self.mapping) {
        id<HYDMapper> mapper = self.mapping[sourceAccessor];

        invertedMapping[mapper.destinationAccessor] = [mapper reverseMapperWithDestinationAccessor:sourceAccessor];
    }
    return invertedMapping;
}

@end


HYD_EXTERN
HYD_OVERLOADED
HYDKeyValueMapper *HYDMapObject(id<HYDAccessor> destinationAccessor, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return [[HYDKeyValueMapper alloc] initWithDestinationAccessor:destinationAccessor
                                                        fromClass:sourceClass
                                                          toClass:destinationClass
                                                          mapping:mapping];
}


HYD_EXTERN
HYD_OVERLOADED
HYDKeyValueMapper *HYDMapObject(id<HYDAccessor> destinationAccessor, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapObject(destinationAccessor, [NSDictionary class], destinationClass, mapping);
}


HYD_EXTERN
HYD_OVERLOADED
HYDKeyValueMapper *HYDMapObject(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapObject(HYDAccessKey(destinationKey), sourceClass, destinationClass, mapping);
}


HYD_EXTERN
HYD_OVERLOADED
HYDKeyValueMapper *HYDMapObject(NSString *destinationKey, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapObject(HYDAccessKey(destinationKey), destinationClass, mapping);
}
