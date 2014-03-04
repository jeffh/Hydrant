#import "HYDTypedObjectMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDTypedMapper.h"
#import "HYDObjectMapper.h"
#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import "HYDFunctions.h"
#import "HYDDefaultAccessor.h"
#import "HYDNonFatalMapper.h"


@interface HYDTypedObjectMapper ()

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;
@property (copy, nonatomic) NSDictionary *mapping;
@property (strong, nonatomic) id<HYDMapper> internalMapper;

@end


@implementation HYDTypedObjectMapper

- (id)initWithMapper:(id<HYDMapper>)mapper sourceClass:(Class)sourceClass destinationClass:(Class)destinationClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.innerMapper = mapper;
        self.sourceClass = sourceClass;
        self.destinationClass = destinationClass;
        self.mapping = HYDNormalizeKeyValueDictionary(mapping, ^id(NSString *key) { return HYDAccessDefault(key); });
    }
    return self;
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
    return [self.internalMapper reverseMapperWithDestinationAccessor:destinationAccessor];
}

#pragma mark - Properties

- (id<HYDMapper>)internalMapper
{
    if (!_internalMapper) {
        _internalMapper = HYDMapType(HYDMapKVCObject(self.innerMapper, self.sourceClass, self.destinationClass, [self buildMapping]),
                                     self.sourceClass, self.destinationClass);
    }
    return _internalMapper;
}

#pragma mark - Private

- (NSDictionary *)buildMapping
{
    NSMutableDictionary *mapping = [NSMutableDictionary dictionaryWithDictionary:self.mapping];
    HYDClassInspector *inspector = [HYDClassInspector inspectorForClass:self.destinationClass];

    NSMutableDictionary *reverseAccessorMapping = [NSMutableDictionary dictionary];
    for (id<HYDAccessor> accessor in self.mapping) {
        id<HYDMapper> mapper = self.mapping[accessor];
        id<HYDAccessor> destinationAccessor = [mapper destinationAccessor];
        reverseAccessorMapping[destinationAccessor] = accessor;
    }

    for (HYDProperty *property in inspector.allProperties) {
        id<HYDAccessor> sourceKey = reverseAccessorMapping[HYDAccessDefault(property.name)];
        if (!sourceKey) {
            continue;
        }

        mapping[sourceKey] = [self mapperForProperty:property wrappingMapper:self.mapping[sourceKey]];
    }

    return mapping;
}

- (id<HYDMapper>)mapperForProperty:(HYDProperty *)property wrappingMapper:(id<HYDMapper>)mapper
{
    // TODO: figure out a better method that isKindOfClass for this check
    BOOL isNonFatal = [mapper isKindOfClass:[HYDNonFatalMapper class]];

    if ([property isObjCObjectType]) {
        Class propertyClass = [property classType];
        mapper = HYDMapTypes(mapper, @[], @[propertyClass, [NSNull class]]);
    } else { // TODO: don't assume a numeric type?
        mapper = HYDMapTypes(mapper, @[], @[[NSNumber class], [NSNull class]]);
    }

    if (isNonFatal) {
        mapper = HYDMapNonFatally(mapper);
    }

    return mapper;
}


@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObject(id<HYDMapper> mapper, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return [[HYDTypedObjectMapper alloc] initWithMapper:mapper
                                            sourceClass:sourceClass
                                       destinationClass:destinationClass
                                                mapping:mapping];
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObject(id<HYDMapper> mapper, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapObject(mapper, [NSDictionary class], destinationClass, mapping);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObject(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapObject(HYDMapIdentity(destinationKey), sourceClass, destinationClass, mapping);
}


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObject(NSString *destinationKey, Class destinationClass, NSDictionary *mapping)
{
    return HYDMapObject(HYDMapIdentity(destinationKey), destinationClass, mapping);
}
