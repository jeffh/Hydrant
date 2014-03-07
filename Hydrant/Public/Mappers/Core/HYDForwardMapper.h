#import "HYDBase.h"
#import "HYDMapper.h"

@interface HYDForwardMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper
        walkAccessor:(id<HYDAccessor>)walkAccessor
         sourceClass:(Class)sourceClass
    destinationClass:(Class)destinationClass;

@end

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(id<HYDAccessor> walkAccessor, Class sourceClass, Class destinationClass, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2,3,4);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(NSString *destinationKey, Class sourceClass, Class destinationClass, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2,3,4);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(id<HYDAccessor> accessor, Class destinationClass, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2,3);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(NSString *destinationKey, Class destinationClass, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2,3);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(id<HYDAccessor> accessor, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2);

HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapForward(NSString *destinationKey, id<HYDMapper> childMapper)
HYD_REQUIRE_NON_NIL(1,2);
