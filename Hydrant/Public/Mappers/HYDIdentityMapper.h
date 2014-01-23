#import "HYDMapper.h"
#import "HYDBase.h"

@interface HYDIdentityMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey;

@end

HYD_EXTERN
HYDIdentityMapper *HYDIdentity(NSString *destinationKey);