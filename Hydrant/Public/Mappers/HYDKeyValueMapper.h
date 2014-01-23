#import "HYDMapper.h"
#import "HYDBase.h"


@class HYDClassInspector;


@interface HYDKeyValueMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) id<HYDFactory> factory;

- (id)initWithDestinationKey:(NSString *)destinationKey
                   fromClass:(Class)sourceClass
                     toClass:(Class)destinationClass
                     mapping:(NSDictionary *)mapping;

@end


HYD_EXTERN
HYDKeyValueMapper *HYDMapObject(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3,4);