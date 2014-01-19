#import "JKSMapper.h"
#import "JKSBase.h"

@interface JKSStringToNumberMapper : NSObject <JKSMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter;

@end

JKS_EXTERN
JKSStringToNumberMapper *JKSStringToNumber(NSString *dstKey);

JKS_EXTERN
JKSStringToNumberMapper *JKSStringToNumberByFormat(NSString *dstKey, NSNumberFormatterStyle numberFormatterStyle);

JKS_EXTERN
JKSStringToNumberMapper *JKSStringToNumberByFormatter(NSString *dstKey, NSNumberFormatter *formatter);
