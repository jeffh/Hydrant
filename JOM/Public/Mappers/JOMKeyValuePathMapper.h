#import "JOMMapper.h"
#import "JOMBase.h"


@interface JOMKeyValuePathMapper : NSObject <JOMMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey
                   fromClass:(Class)sourceClass
                     toClass:(Class)destinationClass
                     mapping:(NSDictionary *)mapping;

@end

JOM_EXTERN
JOMKeyValuePathMapper *JOMMapObjectPath(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping);