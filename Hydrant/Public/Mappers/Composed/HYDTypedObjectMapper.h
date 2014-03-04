#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDTypedObjectMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper
         sourceClass:(Class)sourceClass
    destinationClass:(Class)destinationClass
             mapping:(NSDictionary *)mapping;

@end


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObject(id<HYDMapper> mapper, Class sourceClass, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3,4);


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObject(id<HYDMapper> mapper, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3);


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObject(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3,4);


HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObject(NSString *destinationKey, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3);
