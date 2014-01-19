#import "JKSMapper.h"
#import "JKSBase.h"

@class JKSClassInspector;

@interface JKSKeyValueMapper : NSObject <JKSMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey
                   fromClass:(Class)sourceClass
                     toClass:(Class)destinationClass
                     mapping:(NSDictionary *)mapping;

@end

JKS_EXTERN
JKSKeyValueMapper *JKSMapKeyValuesTo(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping);