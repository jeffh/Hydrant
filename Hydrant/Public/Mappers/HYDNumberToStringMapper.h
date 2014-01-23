#import "HYDBase.h"
#import "HYDMapper.h"

@interface HYDNumberToStringMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter;

@end

HYD_EXTERN
HYDNumberToStringMapper *HYDNumberToString(NSString *destKey);

HYD_EXTERN
HYDNumberToStringMapper *HYDNumberToStringByFormat(NSString *destKey, NSNumberFormatterStyle numberFormatStyle);

HYD_EXTERN
HYDNumberToStringMapper *HYDNumberToStringByFormatter(NSString *destKey, NSNumberFormatter *numberFormatter);
