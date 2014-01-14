#import "JKSMapper.h"
#import "JKSBase.h"

@interface JKSStringToNumberMapper : NSObject <JKSMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter;

@end

JKS_EXTERN
JKSStringToNumberMapper *JKSStringToNumber(NSString *dstKey, NSNumberFormatterStyle numberFormatterStyle);