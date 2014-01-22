#import "JOMBase.h"
#import "JOMMapper.h"


@interface JOMEnumMapper : NSObject <JOMMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey mapping:(NSDictionary *)mapping;

@end

JOM_EXTERN
JOMEnumMapper *JOMEnum(NSString *dstKey, NSDictionary *mapping);
