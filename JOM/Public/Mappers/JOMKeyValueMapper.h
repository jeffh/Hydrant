#import "JOMMapper.h"
#import "JOMBase.h"

@class JOMClassInspector;

@interface JOMKeyValueMapper : NSObject <JOMMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey
                   fromClass:(Class)sourceClass
                     toClass:(Class)destinationClass
                     mapping:(NSDictionary *)mapping;

@end

JOM_EXTERN
JOMKeyValueMapper *JOMMapObject(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping);