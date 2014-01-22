#import "JOMMapper.h"
#import "JOMBase.h"

@interface JOMIdentityMapper : NSObject <JOMMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey;

@end

JOM_EXTERN
JOMIdentityMapper *JOMIdentity(NSString *destinationKey);