#import "HYDReflectiveMapper.h"
#import "HYDConstants.h"
#import "HYDIdentityMapper.h"
#import "HYDIdentityValueTransformer.h"
#import "HYDObjectMapper.h"
#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import "HYDOptionalMapper.h"
#import "HYDTypedMapper.h"
#import "HYDStringToURLMapper.h"
#import "HYDConstants.h"
#import "HYDAccessor.h"
#import "HYDDefaultAccessor.h"
#import "HYDFunctions.h"
#import "HYDStringToNumberMapper.h"
#import "HYDStringToDateMapper.h"
#import "HYDDotNetDateFormatter.h"
#import "HYDFirstMapper.h"
#import "HYDToStringMapper.h"
#import "HYDThreadMapper.h"
#import "HYDStringToUUIDMapper.h"
#import "HYDNumberToDateMapper.h"
#import "HYDMapping.h"
#import "HYDSplitMapper.h"


@interface HYDReflectiveMapper ()

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;

@property (copy, nonatomic) NSSet *optionalFields;
@property (copy, nonatomic) NSSet *requiredFields;
@property (copy, nonatomic) NSSet *onlyFields;
@property (copy, nonatomic) NSSet *excludedFields;
@property (copy, nonatomic) NSDictionary *overriddenMapping;
@property (copy, nonatomic) NSDictionary *typeMapping;
@property (strong, nonatomic) NSValueTransformer *destinationToSourceKeyTransformer;

@property (strong, nonatomic) id<HYDMapper> internalMapper;

- (NSDictionary *)buildMapping;
- (id<HYDMapper>)mapperForProperty:(HYDProperty *)property;

@end


@implementation HYDReflectiveMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)innerMapper
    innerTypesMapper:(id<HYDMapper>)innerTypesMapper
         sourceClass:(Class)sourceClass
    destinationClass:(Class)destinationClass
{
    return [self initWithMapper:innerMapper
                    sourceClass:sourceClass
               destinationClass:destinationClass
                 optionalFields:[NSSet set]
                 requiredFields:nil // setting to non-nil will indicate all other fields are optional.
                     onlyFields:[NSSet set]
                 excludedFields:[NSSet set]
              overriddenMapping:@{}
                    typeMapping:@{NSStringFromClass([NSURL class]): HYDMapStringToURLFrom(innerTypesMapper),
                                  NSStringFromClass([NSUUID class]): HYDMapStringToUUIDFrom(innerTypesMapper),
                                  NSStringFromClass([NSNumber class]): HYDMapStringToNumber(innerTypesMapper),
                                  NSStringFromClass([NSDate class]): HYDMapFirst(HYDMapStringToAnyDate(innerTypesMapper),
                                                                                 HYDMapNumberToDateSince1970(innerTypesMapper)),
                                  NSStringFromClass([NSString class]): innerTypesMapper}
                 keyTransformer:[HYDIdentityValueTransformer new]];
}

- (id)initWithMapper:(id<HYDMapper>)innerMapper
         sourceClass:(Class)sourceClass
    destinationClass:(Class)destinationClass
      optionalFields:(NSSet *)optionalFields
      requiredFields:(NSSet *)requiredFields
          onlyFields:(NSSet *)onlyFields
      excludedFields:(NSSet *)excludedFields
   overriddenMapping:(NSDictionary *)overriddenMapping
         typeMapping:(NSDictionary *)typeMapping
      keyTransformer:(NSValueTransformer *)keyTransformer
{
    NSAssert(!(onlyFields.count && excludedFields.count), @"Ambigious mapping. Cannot have only(%@) and exclude(%@) specified.", onlyFields, excludedFields);
    NSAssert(!(optionalFields.count && requiredFields.count), @"Ambigious mapping. Cannot have optional(%@) and required(%@) specified.", optionalFields, requiredFields);
    self = [super init];
    if (self) {
        self.innerMapper = innerMapper;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.optionalFields = optionalFields;
        self.requiredFields = requiredFields;
        self.onlyFields = onlyFields;
        self.excludedFields = excludedFields;
        self.typeMapping = typeMapping;

        self.overriddenMapping = HYDNormalizeKeyValueDictionary(overriddenMapping, ^id(NSArray *keys) {
            return HYDAccessDefault(keys);
        });
        self.destinationToSourceKeyTransformer = keyTransformer;
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

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    return [self.internalMapper objectFromSourceObject:sourceObject error:error];
}

- (id<HYDMapper>)reverseMapper
{
    return [self.internalMapper reverseMapper];
}

#pragma mark - Public

- (HYDReflectiveMapper *(^)(NSArray *propertyNames))only
{
    return ^(NSArray *propertyNames) {
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:self.optionalFields
                                     requiredFields:self.requiredFields
                                         onlyFields:[NSSet setWithArray:propertyNames]
                                     excludedFields:self.excludedFields
                                  overriddenMapping:self.overriddenMapping
                                        typeMapping:self.typeMapping
                                     keyTransformer:self.destinationToSourceKeyTransformer];
    };
}

- (HYDReflectiveMapper *(^)(Class destinationClass, id<HYDMapper> mapper))mapType
{
    return ^(Class destinationClass, id<HYDMapper> mapper) {
        NSMutableDictionary *newClassMapping = [self.typeMapping mutableCopy];
        newClassMapping[NSStringFromClass(destinationClass)] = mapper;
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:self.optionalFields
                                     requiredFields:self.requiredFields
                                         onlyFields:self.onlyFields
                                     excludedFields:self.excludedFields
                                  overriddenMapping:self.overriddenMapping
                                        typeMapping:newClassMapping
                                     keyTransformer:self.destinationToSourceKeyTransformer];
    };
}

- (HYDReflectiveMapper *(^)(NSArray *))optional
{
    return ^(NSArray *optionalFields) {
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:[NSSet setWithArray:optionalFields]
                                     requiredFields:self.requiredFields
                                         onlyFields:self.onlyFields
                                     excludedFields:self.excludedFields
                                  overriddenMapping:self.overriddenMapping
                                        typeMapping:self.typeMapping
                                     keyTransformer:self.destinationToSourceKeyTransformer];
    };
}

- (HYDReflectiveMapper *(^)(NSArray *))required
{
    return ^(NSArray *requiredFields) {
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:self.optionalFields
                                     requiredFields:[NSSet setWithArray:requiredFields]
                                         onlyFields:self.onlyFields
                                     excludedFields:self.excludedFields
                                  overriddenMapping:self.overriddenMapping
                                        typeMapping:self.typeMapping
                                     keyTransformer:self.destinationToSourceKeyTransformer];
    };
}

- (HYDReflectiveMapper *)withNoRequiredFields
{
    return self.required(@[]);
}

- (HYDReflectiveMapper *(^)(NSArray *))except
{
    return ^(NSArray *excludedFields) {
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:self.optionalFields
                                     requiredFields:self.requiredFields
                                         onlyFields:self.onlyFields
                                     excludedFields:[NSSet setWithArray:excludedFields]
                                  overriddenMapping:self.overriddenMapping
                                        typeMapping:self.typeMapping
                                     keyTransformer:self.destinationToSourceKeyTransformer];
    };
}

- (HYDReflectiveMapper *(^)(NSDictionary *))customMapping
{
    return ^(NSDictionary *overriddenMapping) {
        NSMutableDictionary *mapping = [NSMutableDictionary dictionaryWithDictionary:self.overriddenMapping];
        [mapping addEntriesFromDictionary:overriddenMapping];
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:self.optionalFields
                                     requiredFields:self.requiredFields
                                         onlyFields:self.onlyFields
                                     excludedFields:self.excludedFields
                                  overriddenMapping:mapping
                                        typeMapping:self.typeMapping
                                     keyTransformer:self.destinationToSourceKeyTransformer];
    };
}

- (HYDReflectiveMapper *(^)(NSValueTransformer *propertyToSourceKeyTransformer))keyTransformer
{
    return ^(NSValueTransformer *propertyToSourceKeyTransformer) {
        return [[[self class] alloc] initWithMapper:self.innerMapper
                                        sourceClass:self.sourceClass
                                   destinationClass:self.destinationClass
                                     optionalFields:self.optionalFields
                                     requiredFields:self.requiredFields
                                         onlyFields:self.onlyFields
                                     excludedFields:self.excludedFields
                                  overriddenMapping:self.overriddenMapping
                                        typeMapping:self.typeMapping
                                     keyTransformer:propertyToSourceKeyTransformer];
    };
}

#pragma mark - Private

- (id<HYDMapper>)internalMapper
{
    if (!_internalMapper) {
        _internalMapper = HYDMapType(HYDMapKVCObject(self.innerMapper, self.sourceClass, self.destinationClass, [self buildMapping]),
                                     self.sourceClass, self.destinationClass);
    }
    return _internalMapper;
}

#pragma mark - Protected

- (NSDictionary *)buildMapping
{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    HYDClassInspector *inspector = [HYDClassInspector inspectorForClass:self.destinationClass];

    for (HYDProperty *property in inspector.allProperties) {
        NSString *sourceKey = [self.destinationToSourceKeyTransformer transformedValue:property.name];
        NSString *destinationKey = property.name;
        if (!sourceKey || !destinationKey) {
            continue;
        }

        if (self.onlyFields.count && ![self.onlyFields containsObject:destinationKey]) {
            continue;
        }

        if ([self.excludedFields containsObject:destinationKey]) {
            continue;
        }

        id<HYDMapper> mapper = HYDMapNotNullFrom([self mapperForProperty:property]);
        if ([self fieldShouldBeOptional:destinationKey]) {
            mapper = HYDMapNonFatally(mapper);
        }

        results[sourceKey] = HYDMap(mapper, HYDAccessDefault(destinationKey));
    }

    results = [HYDNormalizeKeyValueDictionary(results, ^id<HYDAccessor>(NSArray *fields) {
        return HYDAccessDefault(fields);
    }) mutableCopy];

    [results addEntriesFromDictionary:self.overriddenMapping];
    return results;
}

- (id<HYDMapper>)mapperForProperty:(HYDProperty *)property
{
    id<HYDMapper> mapper = HYDMapIdentity();

    if ([property isObjCObjectType]) {
        Class propertyClass = [property classType];
        id<HYDMapper> classMapper = self.typeMapping[NSStringFromClass(propertyClass)];
        mapper = HYDMapType(classMapper ?: mapper, nil, propertyClass);
    }

    return mapper;
}

- (BOOL)fieldShouldBeOptional:(NSString *)field
{
    if (self.optionalFields.count && [self.optionalFields containsObject:field]) {
        return YES;
    }
    if (self.requiredFields && ![self.requiredFields containsObject:field]) {
        return YES;
    }
    return NO;
}

@end


HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(id<HYDMapper> innerMapper, Class sourceClass, Class destinationClass)
{
    return [[HYDReflectiveMapper alloc] initWithMapper:innerMapper
                                      innerTypesMapper:HYDMapSplit(HYDMapToString(), HYDMapIdentity())
                                           sourceClass:sourceClass
                                      destinationClass:destinationClass];
}

HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(id<HYDMapper> innerMapper, Class destinationClass)
{
    return HYDMapReflectively(innerMapper, [NSDictionary class], destinationClass);
}

HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(Class sourceClass, Class destinationClass)
{
    return HYDMapReflectively(HYDMapIdentity(), sourceClass, destinationClass);
}

HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(Class destinationClass)
{
    return HYDMapReflectively([NSDictionary class], destinationClass);
}
