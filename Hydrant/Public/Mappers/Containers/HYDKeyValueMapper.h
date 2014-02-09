#import "HYDMapper.h"
#import "HYDBase.h"


@class HYDClassInspector;
@protocol HYDAccessor;


@interface HYDKeyValueMapper : NSObject <HYDMapper>

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
                        fromClass:(Class)sourceClass
                          toClass:(Class)destinationClass
                          mapping:(NSDictionary *)mapping;

@end


HYD_EXTERN
HYD_OVERLOADED
HYDKeyValueMapper *HYDMapObject(id<HYDAccessor> destinationAccessor, Class sourceClass, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3,4);


HYD_EXTERN
HYD_OVERLOADED
HYDKeyValueMapper *HYDMapObject(id<HYDAccessor> destinationAccessor, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3);


/*! Constructs a mapper that maps properties from source object to a destination object
 *  using Key Value Coding.
 *
 *  This essentially uses -[valueForKey:] and -[setValue:forKey:] to do all its mapping.
 *  All child mappers are mapped to their corresponding destinationAccessor they provide as the
 *  key value.
 *
 *  The destinationClass is created using [[[destinationClass alloc] init] mutableCopy]. The
 *  mutableCopy is used to ensure NSArray and NSDictionary constructors work.
 *
 *  @param destinationAccessor the property hint to store key value.
 *  @param sourceClass the source object type. This is used when generating a reverse mapper.
 *  @param destinationClass the destination object type. This is created by the mapper.
 *  @returns a mapper that maps properties from the source object to the destination object.
 *  @see HYDMapObjectPath for a similar mapper which uses key paths.
 */
HYD_EXTERN
HYD_OVERLOADED
HYDKeyValueMapper *HYDMapObject(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3,4);

/*! Constructs a mapper that maps properties from an NSDictionary to a destination object
 *  using Key Value Coding. This is shorthand for setting [NSDictionary class] as the sourceClass.
 *
 *  This essentially uses -[valueForKey:] and -[setValue:forKey:] to do all its mapping.
 *  All child mappers are mapped to their corresponding destinationAccessor they provide as the
 *  key value.
 *
 *  The destinationClass is created using [[[destinationClass alloc] init] mutableCopy]. The
 *  mutableCopy is used to ensure NSArray and NSDictionary constructors work.
 *
 *  @param destinationAccessor the property hint to store key value.
 *  @param destinationClass the destination object type. This is created by the mapper.
 *  @returns a mapper that maps properties from the source object to the destination object.
 *  @see HYDMapObjectPath for a similar mapper which uses key paths.
 */
HYD_EXTERN
HYD_OVERLOADED
HYDKeyValueMapper *HYDMapObject(NSString *destinationKey, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3);
