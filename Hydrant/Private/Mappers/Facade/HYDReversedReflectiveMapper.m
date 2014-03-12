#import "HYDReversedReflectiveMapper.h"
#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import "HYDOptionalMapper.h"
#import "HYDDefaultAccessor.h"
#import "HYDReflectiveMapper+Protected.h"
#import "HYDMapping.h"


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

        id<HYDMapper> mapper = HYDMapNotNullFrom([self mapperForProperty:property]);
        if ([optionalFields containsObject:sourceKey]) {
            mapper = HYDMapNonFatally(mapper);
        }
        mapping[sourceKey] = HYDMap(mapper, HYDAccessDefault(destinationKey));
    }

    [mapping addEntriesFromDictionary:self.overriddenMapping];
    return mapping;
}

- (id<HYDMapper>)mapperForProperty:(HYDProperty *)property
{
    id<HYDMapper> mapper = [super mapperForProperty:property];
    return [mapper reverseMapper];
}

@end
