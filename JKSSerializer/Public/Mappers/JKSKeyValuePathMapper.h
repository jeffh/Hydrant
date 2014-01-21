#import "JKSMapper.h"
#import "JKSBase.h"


@interface JKSKeyValuePathMapper : NSObject <JKSMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey
                   fromClass:(Class)sourceClass
                     toClass:(Class)destinationClass
                     mapping:(NSDictionary *)mapping;

@end

JKS_EXTERN
JKSKeyValuePathMapper *JKSMapObjectPath(NSString *destinationKey, Class sourceClass, Class destinationClass, NSDictionary *mapping);