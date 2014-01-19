#import "JKSBase.h"
#import "JKSMapper.h"

@interface JKSNumberToStringMapper : NSObject <JKSMapper>

@property (strong, nonatomic) NSString *destinationKey;
@property (assign, nonatomic) BOOL convertsToNumber;

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter;

@end

JKS_EXTERN
JKSNumberToStringMapper *JKSNumberToString(NSString *destKey);

JKS_EXTERN
JKSNumberToStringMapper *JKSNumberToStringByFormat(NSString *destKey, NSNumberFormatterStyle numberFormatStyle);

JKS_EXTERN
JKSNumberToStringMapper *JKSNumberToStringByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter);
