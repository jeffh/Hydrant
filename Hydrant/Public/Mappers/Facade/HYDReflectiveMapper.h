#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDReflectiveMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)innerMapper
    innerTypesMapper:(id<HYDMapper>)innerTypesMapper
         sourceClass:(Class)sourceClass
    destinationClass:(Class)destinationClass;

/// A factory that returns a new mapper that maps a given class using a specified mapper.
@property (strong, nonatomic, readonly) HYDReflectiveMapper *(^mapType)(Class destinationClass, id<HYDMapper> mapper);

/// A factory that returns a new mapper that makes the destination properties optional.
/// It cannot be used with required. By default reflective mappers require all fields.
@property (strong, nonatomic, readonly) HYDReflectiveMapper *(^optional)(NSArray *propertyNames);

/// A factory that returns a new mapper that makes the destination properties required.
/// It cannot be used with optional. By default reflective mappers require all fields.
/// Passing an empty array will make all fields optional
@property (strong, nonatomic, readonly) HYDReflectiveMapper *(^required)(NSArray *propertyNames);

/// Alias to doing required(@[])
@property (strong, nonatomic, readonly) HYDReflectiveMapper *withNoRequiredFields;

/// A factory that returns a new mapper that maps only the specified destination properties. Cannot be used with except().
@property (strong, nonatomic, readonly) HYDReflectiveMapper *(^only)(NSArray *propertyNames);

/// A factory that returns a new mapper that does not map the specified properties. Cannot be used with only().
@property (strong, nonatomic, readonly) HYDReflectiveMapper *(^except)(NSArray *propertyNames);

/// A factory that returns a new mapper that allows you to specify custom mapping for given properties.
/// This is equivalent to using HYDMapObject.
@property (strong, nonatomic, readonly) HYDReflectiveMapper *(^customMapping)(NSDictionary *mappingOverrides);

/// A factory that returns a new mapper that uses the given value transformer.
/// The value transformer is given the destination key and excepts the source key to read from.
/// (eg - it uses the property name to figure out the JSON key to read from).
@property (strong, nonatomic, readonly) HYDReflectiveMapper *(^keyTransformer)(NSValueTransformer *keyTransformer);

@end

/*! Constructs a Reflective Mapper which provides simplier API to using a subset of Hydrant's features.
 *
 *  @param innerMapper The mapper that preprocesses the source object before the reflective mapper receives it.
 *  @param sourceClass The expected source class to receive. The reflective mapper will type check this.
 *  @param destinationClass The expected output class to product. The reflective mapper will use introspection to
 *                          try and intelligently deduce the correct mapping.
 *  @returns a HYDReflectiveMapper additional things can be changed after construction.
 */
HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(id<HYDMapper> innerMapper, Class sourceClass, Class destinationClass)
HYD_REQUIRE_NON_NIL(2,3);

/*! Constructs a Reflective Mapper which provides simplier API to using a subset of Hydrant's features.
 *  The sourceClass is implicitly [NSDictionary class].
 *
 *  @param innerMapper The mapper that preprocesses the source object before the reflective mapper receives it.
 *  @param destinationClass The expected output class to product. The reflective mapper will use introspection to
 *                          try and intelligently deduce the correct mapping.
 *  @returns a HYDReflectiveMapper additional things can be changed after construction.
 */
HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(id<HYDMapper> innerMapper, Class destinationClass)
HYD_REQUIRE_NON_NIL(2);

/*! Constructs a Reflective Mapper which provides simplier API to using a subset of Hydrant's features.
 *  The sourceClass is implicitly [NSDictionary class].
 *
 *  @param sourceClass The expected source class to receive. The reflective mapper will type check this.
 *  @param destinationClass The expected output class to product. The reflective mapper will use introspection to
 *                          try and intelligently deduce the correct mapping.
 *  @returns a HYDReflectiveMapper additional things can be changed after construction.
 */
HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(Class sourceClass, Class destinationClass)
HYD_REQUIRE_NON_NIL(1,2);

/*! Constructs a Reflective Mapper which provides simplier API to using a subset of Hydrant's features.
 *  The sourceClass is implicitly [NSDictionary class].
 *
 *  @param destinationClass The expected output class to product. The reflective mapper will use introspection to
 *                          try and intelligently deduce the correct mapping.
 *  @returns a HYDReflectiveMapper additional things can be changed after construction.
 */
HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(Class destinationClass)
HYD_REQUIRE_NON_NIL(1);
