#import "HYDKeyValueMapper.h"
#import "HYDFactory.h"
#import "HYDObjectFactory.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDDefaultAccessor.h"
#import "HYDIdentityMapper.h"


@interface HYDKeyValueMapper ()

@property (strong, nonatomic, readwrite) id<HYDMapper> innerMapper;
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

- (id)initWithMapper:(id<HYDMapper>)mapper fromClass:(Class)sourceClass toClass:(Class)destinationClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.innerMapper = mapper;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.mapping = HYDNormalizeKeyValueDictionary(mapping, ^id(NSString *key) { return HYDAccessDefault(key); });
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
            // TODO: test wrapping error
            [errors addObject:[HYDError errorFromError:innerError
                              prependingSourceAccessor:sourceAccessor
                                andDestinationAccessor:nil
                               replacementSourceObject:nil
                                               isFatal:YES]];
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

        id<HYDAccessor> destinationAccessor = [mapper destinationAccessor];

        if (destinationAccessor.fieldNames.count == 1) {
            destinationValue = @[destinationValue];
        }

        [[mapper destinationAccessor] setValues:destinationValue
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
    id<HYDMapper> reversedInnerMapper = [self.innerMapper reverseMapperWithDestinationAccessor:destinationAccessor];
    return [[[self class] alloc] initWithMapper:reversedInnerMapper
                                      fromClass:self.destinationClass
                                        toClass:self.sourceClass
                                        mapping:[self inverseMapping]];

}

- (id<HYDAccessor>)destinationAccessor
{
    return [self.innerMapper destinationAccessor];
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


HYD_EXTERN_OVERLOADED
HYDKeyValueMapper *HYDMapObject(id<HYDMapper> mapper, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return [[HYDKeyValueMapper alloc] initWithMapper:mapper
                                           fromClass:sourceClass
                                             toClass:destinationClass
                                             mapping:mapping];
}


HYD_EXTERN_OVERLOADED
HYDKeyValueMapper *HYDMapObject(id<HYDMapper> mapper, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapObject(mapper, [NSDictionary class], destinationClass, mapping);
}


HYD_EXTERN_OVERLOADED
HYDKeyValueMapper *HYDMapObject(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapObject(HYDMapIdentity(destinationKey), sourceClass, destinationClass, mapping);
}


HYD_EXTERN_OVERLOADED
HYDKeyValueMapper *HYDMapObject(NSString *destinationKey, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapObject(HYDMapIdentity(destinationKey), destinationClass, mapping);
}
