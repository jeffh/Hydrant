#import "HYDReflectiveMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDIdentityValueTransformer.h"
#import "HYDBlockValueTransformer.h"
#import "HYDObjectMapper.h"
#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import "HYDOptionalMapper.h"
#import "HYDTypedMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDConstants.h"


@interface HYDReflectiveMapper ()

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;

@property (copy, nonatomic) NSSet *optionalFields;
@property (copy, nonatomic) NSSet *excludedFields;
@property (copy, nonatomic) NSDictionary *overriddenMapping;
@property (strong, nonatomic) NSValueTransformer *propertyNameToSourceKeyTransformer;

@property (strong, nonatomic) id<HYDMapper> internalMapper;

@end


@implementation HYDReflectiveMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)innerMapper sourceClass:(Class)sourceClass destinationClass:(Class)destinationClass
{
    return [self initWithMapper:innerMapper
                    sourceClass:sourceClass
               destinationClass:destinationClass
                 optionalFields:[NSSet set]
                 excludedFields:[NSSet set]
              overriddenMapping:@{}
                 keyTransformer:[HYDIdentityValueTransformer new]];
}

- (id)initWithMapper:(id<HYDMapper>)innerMapper
         sourceClass:(Class)sourceClass
    destinationClass:(Class)destinationClass
      optionalFields:(NSSet *)optionalFields
      excludedFields:(NSSet *)excludedFields
   overriddenMapping:(NSDictionary *)overriddenMapping
      keyTransformer:(NSValueTransformer *)keyTransformer
{
    self = [super init];
    if (self) {
        self.innerMapper = innerMapper;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.optionalFields = optionalFields;
        self.excludedFields = excludedFields;
        self.overriddenMapping = overriddenMapping;
        self.propertyNameToSourceKeyTransformer = keyTransformer;
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@ -> %@>",
            NSStringFromClass(self.class),
            NSStringFromClass(self.sourceClass),
            NSStringFromClass(self.destinationClass)];
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    return [self.internalMapper objectFromSourceObject:sourceObject error:error];
}

- (id<HYDAccessor>)destinationAccessor
{
    return [self.innerMapper destinationAccessor];
}

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    return nil;
}

#pragma mark - Public

- (HYDReflectiveMapper *(^)(NSArray *))optional
{
    return ^(NSArray *optionalFields) {
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:[NSSet setWithArray:optionalFields]
                                     excludedFields:self.excludedFields
                                  overriddenMapping:self.overriddenMapping
                                     keyTransformer:self.keyTransformer];
    };
}

- (HYDReflectiveMapper *(^)(NSArray *))excluding
{
    return ^(NSArray *excludedFields) {
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:self.optionalFields
                                     excludedFields:[NSSet setWithArray:excludedFields]
                                  overriddenMapping:self.overriddenMapping
                                     keyTransformer:self.keyTransformer];
    };
}

- (HYDReflectiveMapper *(^)(NSDictionary *))overriding
{
    return ^(NSDictionary *overriddenMapping) {
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:self.optionalFields
                                     excludedFields:self.excludedFields
                                  overriddenMapping:[overriddenMapping copy]
                                     keyTransformer:self.keyTransformer];
    };
}

- (HYDReflectiveMapper *(^)(KeyTransformBlock))keyTransform
{
    return ^(KeyTransformBlock keyTransformBlock) {
        return self.keyTransformer([[HYDBlockValueTransformer alloc] initWithBlock:keyTransformBlock]);
    };
}

- (HYDReflectiveMapper *(^)(NSValueTransformer *propertyToSourceKeyTransformer))keyTransformer
{
    return ^(NSValueTransformer *propertyToSourceKeyTransformer) {
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:self.optionalFields
                                     excludedFields:self.excludedFields
                                  overriddenMapping:self.overriddenMapping
                                     keyTransformer:propertyToSourceKeyTransformer];
    };
}

#pragma mark - Private

- (id<HYDMapper>)internalMapper
{
    if (!_internalMapper) {
        _internalMapper = HYDMapObject(self.innerMapper, self.sourceClass, self.destinationClass, [self buildMapping]);
        _internalMapper = HYDMapType(_internalMapper, self.sourceClass, self.destinationClass);
    }
    return _internalMapper;
}

- (NSDictionary *)buildMapping
{
    NSSet *optionalFields = self.optionalFields;
    NSSet *excludedFields = self.excludedFields;

    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];

    HYDClassInspector *destinationInspector = [HYDClassInspector inspectorForClass:self.destinationClass];

    for (HYDProperty *property in destinationInspector.allProperties) {
        if ([excludedFields containsObject:property.name]) {
            continue;
        }

        NSString *sourceKey = [self.propertyNameToSourceKeyTransformer transformedValue:property.name];
        if (!sourceKey) {
            continue;
        }

        id<HYDMapper> mapper = HYDMapNotNull([self mapperForProperty:property]);
        if ([optionalFields containsObject:property.name]) {
            mapper = HYDMapNonFatally(mapper);
        }
        mapping[sourceKey] = mapper;
    }

    [mapping addEntriesFromDictionary:self.overriddenMapping];
    return mapping;
}

- (id<HYDMapper>)mapperForProperty:(HYDProperty *)property
{
    id<HYDMapper> mapper = HYDMapIdentity(property.name);
    if ([property isObjCObjectType]) {
        Class propertyClass = [property classType];
        if ([propertyClass isSubclassOfClass:[NSDate class]]) {
            mapper = HYDMapStringToDate(mapper, HYDDateFormatRFC3339);
        }
    }
    return mapper;
}

@end


HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(id<HYDMapper> innerMapper, Class sourceClass, Class destinationClass)
{
    return [[HYDReflectiveMapper alloc] initWithMapper:innerMapper
                                           sourceClass:sourceClass
                                      destinationClass:destinationClass];
}

HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(id<HYDMapper> innerMapper, Class destinationClass)
{
    return HYDMapReflectively(innerMapper, [NSDictionary class], destinationClass);
}

HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(NSString *destinationKey, Class sourceClass, Class destinationClass)
{
    return HYDMapReflectively(HYDMapIdentity(destinationKey), sourceClass, destinationClass);
}

HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(NSString *destinationKey, Class destinationClass)
{
    return HYDMapReflectively(destinationKey, [NSDictionary class], destinationClass);
}
