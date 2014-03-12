#import "HYDBase.h"
#import "HYDMapper.h"


@class HYDClassInspector;


@interface HYDObjectMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper
           fromClass:(Class)sourceClass
             toClass:(Class)destinationClass
             mapping:(NSDictionary *)mapping;

@end

/*! Constructs a mapper that maps properties from an NSDictionary to a destination object
 *  using Key Value Coding. This is shorthand for setting [NSDictionary class] as the sourceClass.
 *
 *  The destinationClass is created using [[[destinationClass alloc] init] mutableCopy]. The
 *  mutableCopy is used to ensure NSArray and NSDictionary constructors work.
 *
 *  @param mapper the property hint to store key value.
 *  @param destinationClass the destination object type. This is created by the mapper.
 *  @returns a mapper that maps properties from the source object to the destination object.
 *  @see HYDMapObjectPath for a similar mapper which uses key paths.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapKVCObject(id<HYDMapper> mapper, Class sourceClass, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3,4);

/*! Constructs a mapper that maps properties from an NSDictionary to a destination object
 *  using Key Value Coding. This is shorthand for setting [NSDictionary class] as the sourceClass.
 *
 *  The destinationClass is created using [[[destinationClass alloc] init] mutableCopy]. The
 *  mutableCopy is used to ensure NSArray and NSDictionary constructors work.
 *
 *  @param mapper the property hint to store key value.
 *  @param destinationClass the destination object type. This is created by the mapper.
 *  @returns a mapper that maps properties from the source object to the destination object.
 *  @see HYDMapObjectPath for a similar mapper which uses key paths.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapKVCObject(id<HYDMapper> mapper, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3);

/*! Constructs a mapper that maps properties from a source object to a destination object
 *  using Key Value Coding.
 *
 *  The destinationClass is created using [[[destinationClass alloc] init] mutableCopy]. The
 *  mutableCopy is used to ensure NSArray and NSDictionary constructors work.
 *
 *  @param sourceClass the source object type. This is used when generating a reverse mapper.
 *  @param destinationClass the destination object type. This is created by the mapper.
 *  @returns a mapper that maps properties from the source object to the destination object.
 *  @see HYDMapObjectPath for a similar mapper which uses key paths.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapKVCObject(Class sourceClass, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3);

/*! Constructs a mapper that maps properties from an NSDictionary to a destination object
 *  using Key Value Coding. This is shorthand for setting [NSDictionary class] as the sourceClass.
 *
 *  The destinationClass is created using [[[destinationClass alloc] init] mutableCopy]. The
 *  mutableCopy is used to ensure NSArray and NSDictionary constructors work.
 *
 *  @param destinationClass the destination object type. This is created by the mapper.
 *  @returns a mapper that maps properties from the source object to the destination object.
 *  @see HYDMapObjectPath for a similar mapper which uses key paths.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapKVCObject(Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2);
