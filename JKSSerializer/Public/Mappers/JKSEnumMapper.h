#import "JKSBase.h"
#import "JKSMapper.h"


@interface JKSEnumMapper : NSObject <JKSMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey mapping:(NSDictionary *)mapping;

@end

JKS_EXTERN
JKSEnumMapper* JKSEnum(NSString *dstKey, NSDictionary *mapping);
