#import "HYDObjectMapper.h"
#import "HYDFactory.h"
#import "HYDObjectFactory.h"
#import "HYDError.h"
#import "HYDFunctions.h"
#import "HYDDefaultAccessor.h"
#import "HYDIdentityMapper.h"
#import "HYDMapping.h"


@interface HYDObjectMapper ()

@property (strong, nonatomic, readwrite) id<HYDMapper> innerMapper;
@property (strong, nonatomic, readwrite) Class sourceClass;
@property (strong, nonatomic, readwrite) Class destinationClass;
@property (strong, nonatomic, readwrite) NSDictionary *mapping;
@property (strong, nonatomic, readwrite) id<HYDFactory> factory;

@end


@implementation HYDObjectMapper

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

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@ -> %@ with %@>",
            NSStringFromClass(self.class),
            self.sourceClass,
            self.destinationClass,
            self.mapping];
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
        id<HYDMapping> mapping = self.mapping[sourceAccessor];
        id<HYDMapper> mapper = [mapping mapper];
        id<HYDAccessor> destinationAccessor = [mapping accessor];
        HYDError *innerError = nil;

        NSArray *sourceValues = [sourceAccessor valuesFromSourceObject:sourceObject error:&innerError];
        if (innerError) {
            hasFatalError = hasFatalError || [innerError isFatal];
            [errors addObject:[HYDError errorWithCode:HYDErrorGetViaAccessorFailed
                                         sourceObject:innerError.sourceObject
                                       sourceAccessor:sourceAccessor
                                    destinationObject:innerError.destinationObject
                                  destinationAccessor:destinationAccessor
                                              isFatal:innerError.isFatal
                                     underlyingErrors:nil]];
            continue;
        }

        id sourceValue = HYDGetValueOrValues(sourceValues);

        id destinationValue = [mapper objectFromSourceObject:sourceValue
                                                       error:&innerError];

        if (innerError) {
            hasFatalError = hasFatalError || [innerError isFatal];
            [errors addObject:[HYDError errorFromError:innerError
                              prependingSourceAccessor:sourceAccessor
                                andDestinationAccessor:[mapping accessor]
                               replacementSourceObject:sourceValue
                                               isFatal:innerError.isFatal]];
        }

        if ([innerError isFatal]) {
            continue;
        }

        if (!destinationValue) {
            destinationValue = [NSNull null];
        }

        if (destinationAccessor.fieldNames.count == 1) {
            destinationValue = @[destinationValue];
        }

        HYDError *setterError = [destinationAccessor setValues:destinationValue
                                                      onObject:destinationObject];
        if (setterError) {
            hasFatalError = hasFatalError || [setterError isFatal];
            [errors addObject:[HYDError errorWithCode:setterError.code
                                         sourceObject:sourceObject
                                       sourceAccessor:sourceAccessor
                                    destinationObject:setterError.destinationObject
                                  destinationAccessor:setterError.destinationAccessor
                                              isFatal:setterError.isFatal
                                     underlyingErrors:nil]];
        }
    }

    if (errors.count) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:HYDErrorMultipleErrors
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:nil
                                                   isFatal:hasFatalError
                                          underlyingErrors:errors]);
    }

    if (hasFatalError) {
        return nil;
    }

    return destinationObject;
}

- (id<HYDMapper>)reverseMapper
{
    id<HYDMapper> reversedInnerMapper = [self.innerMapper reverseMapper];
    return [[[self class] alloc] initWithMapper:reversedInnerMapper
                                      fromClass:self.destinationClass
                                        toClass:self.sourceClass
                                        mapping:HYDReversedKeyValueDictionary(self.mapping)];

}

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapKVCObject(id<HYDMapper> mapper, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return [[HYDObjectMapper alloc] initWithMapper:mapper
                                         fromClass:sourceClass
                                           toClass:destinationClass
                                           mapping:mapping];
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapKVCObject(id<HYDMapper> mapper, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapKVCObject(mapper, [NSDictionary class], destinationClass, mapping);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapKVCObject(Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapKVCObject(HYDMapIdentity(), sourceClass, destinationClass, mapping);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapKVCObject( Class destinationClass, NSDictionary *mapping)
{
    return HYDMapKVCObject(HYDMapIdentity(), destinationClass, mapping);
}
