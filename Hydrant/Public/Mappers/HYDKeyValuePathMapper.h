#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDKeyValuePathMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) id<HYDFactory> factory;

- (id)initWithDestinationKey:(NSString *)destinationKey
                   fromClass:(Class)sourceClass
                     toClass:(Class)destinationClass
                     mapping:(NSDictionary *)mapping;

@end


HYD_EXTERN
HYDKeyValuePathMapper *HYDMapObjectPath(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping);