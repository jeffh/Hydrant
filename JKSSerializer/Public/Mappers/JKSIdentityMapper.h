#import "JKSMapper.h"
#import "JKSBase.h"

@interface JKSIdentityMapper : NSObject <JKSMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey;

@end

JKS_EXTERN
JKSIdentityMapper *JKSIdentity(NSString *destinationKey);