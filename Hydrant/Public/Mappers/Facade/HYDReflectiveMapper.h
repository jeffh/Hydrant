#import "HYDBase.h"
#import "HYDMapper.h"


typedef NSString *(^KeyTransformBlock)(NSString *propertyName);


@interface HYDReflectiveMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)innerMapper
         sourceClass:(Class)sourceClass
    destinationClass:(Class)destinationClass;

@property (weak, nonatomic, readonly) HYDReflectiveMapper *(^mapClass)(Class destinationClass, id<HYDMapper> mapper);
@property (weak, nonatomic, readonly) HYDReflectiveMapper *(^optional)(NSArray *propertyNames);
@property (weak, nonatomic, readonly) HYDReflectiveMapper *(^excluding)(NSArray *propertyNames);
@property (weak, nonatomic, readonly) HYDReflectiveMapper *(^overriding)(NSDictionary *mappingOverrides);
@property (weak, nonatomic, readonly) HYDReflectiveMapper *(^keyTransformer)(NSValueTransformer *keyTransformer);

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
 *  @param destinationKey The property hint to indicate where this mapper's results should be stored to.
 *  @param sourceClass The expected source class to receive. The reflective mapper will type check this.
 *  @param destinationClass The expected output class to product. The reflective mapper will use introspection to
 *                          try and intelligently deduce the correct mapping.
 *  @returns a HYDReflectiveMapper additional things can be changed after construction.
 */
HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(NSString *destinationKey, Class sourceClass, Class destinationClass)
HYD_REQUIRE_NON_NIL(2,3);

/*! Constructs a Reflective Mapper which provides simplier API to using a subset of Hydrant's features.
 *  The sourceClass is implicitly [NSDictionary class].
 *
 *  @param destinationKey The property hint to indicate where this mapper's results should be stored to.
 *  @param destinationClass The expected output class to product. The reflective mapper will use introspection to
 *                          try and intelligently deduce the correct mapping.
 *  @returns a HYDReflectiveMapper additional things can be changed after construction.
 */
HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(NSString *destinationKey, Class destinationClass)
HYD_REQUIRE_NON_NIL(2);
