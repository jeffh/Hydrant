#import "JOMBase.h"
#import "JOMMapper.h"

@interface JOMNumberToStringMapper : NSObject <JOMMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter;

@end

JOM_EXTERN
JOMNumberToStringMapper *JOMNumberToString(NSString *destKey);

JOM_EXTERN
JOMNumberToStringMapper *JOMNumberToStringByFormat(NSString *destKey, NSNumberFormatterStyle numberFormatStyle);

JOM_EXTERN
JOMNumberToStringMapper *JOMNumberToStringByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter);
