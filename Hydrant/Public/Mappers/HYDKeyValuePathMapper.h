#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDKeyValuePathMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey
                   fromClass:(Class)sourceClass
                     toClass:(Class)destinationClass
                     mapping:(NSDictionary *)mapping;

@end


HYD_EXTERN
HYDKeyValuePathMapper *HYDMapObjectPath(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping)
HYD_REQUIRE_NON_NIL(2,3,4);