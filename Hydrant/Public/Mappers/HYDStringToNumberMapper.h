#import "HYDMapper.h"
#import "HYDBase.h"

@interface HYDStringToNumberMapper : NSObject <HYDMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter;

@end

HYD_EXTERN
HYDStringToNumberMapper *HYDStringToNumber(NSString *dstKey);

HYD_EXTERN
HYDStringToNumberMapper *HYDStringToNumberByFormat(NSString *dstKey, NSNumberFormatterStyle numberFormatterStyle);

HYD_EXTERN
HYDStringToNumberMapper *HYDStringToNumberByFormatter(NSString *dstKey, NSNumberFormatter *formatter);
