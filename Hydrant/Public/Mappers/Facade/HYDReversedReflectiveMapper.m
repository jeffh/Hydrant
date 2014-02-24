#import "HYDReversedReflectiveMapper.h"
#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import "HYDMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDOptionalMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDConstants.h"


@interface HYDReflectiveMapper (Protected)

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;

@property (copy, nonatomic) NSSet *optionalFields;
@property (copy, nonatomic) NSSet *excludedFields;
@property (copy, nonatomic) NSDictionary *overriddenMapping;
@property (strong, nonatomic) NSValueTransformer *destinationToSourceKeyTransformer;

@property (strong, nonatomic) id<HYDMapper> internalMapper;

- (NSDictionary *)buildMapping;
- (id<HYDMapper>)mapperForProperty:(HYDProperty *)property;

@end


@implementation HYDReversedReflectiveMapper

#pragma mark - Protected

- (NSDictionary *)buildMapping
{
    NSSet *optionalFields = self.optionalFields;
    NSSet *excludedFields = self.excludedFields;

    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];

    HYDClassInspector *inspector = [HYDClassInspector inspectorForClass:self.sourceClass];

    for (HYDProperty *property in inspector.allProperties) {
        NSString *sourceKey = property.name;
        NSString *destinationKey = [self.destinationToSourceKeyTransformer reverseTransformedValue:sourceKey];
        if (!sourceKey || !destinationKey) {
            continue;
        }

        if ([excludedFields containsObject:sourceKey]) {
            continue;
        }

        id<HYDMapper> mapper = HYDMapNotNull([self mapperForProperty:property destinationKey:destinationKey]);
        if ([optionalFields containsObject:sourceKey]) {
            mapper = HYDMapNonFatally(mapper);
        }
        mapping[sourceKey] = mapper;
    }

    [mapping addEntriesFromDictionary:self.overriddenMapping];
    return mapping;
}

- (id<HYDMapper>)mapperForProperty:(HYDProperty *)property destinationKey:(NSString *)destinationKey
{
    id<HYDMapper> mapper = HYDMapIdentity(destinationKey);
    if ([property isObjCObjectType]) {
        Class propertyClass = [property classType];
        if ([propertyClass isSubclassOfClass:[NSDate class]]) {
            mapper = HYDMapDateToString(mapper, HYDDateFormatRFC3339);
        }
    }
    return mapper;
}

@end
