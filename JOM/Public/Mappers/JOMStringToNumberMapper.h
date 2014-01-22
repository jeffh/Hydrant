#import "JOMMapper.h"
#import "JOMBase.h"

@interface JOMStringToNumberMapper : NSObject <JOMMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter;

@end

JOM_EXTERN
JOMStringToNumberMapper *JOMStringToNumber(NSString *dstKey);

JOM_EXTERN
JOMStringToNumberMapper *JOMStringToNumberByFormat(NSString *dstKey, NSNumberFormatterStyle numberFormatterStyle);

JOM_EXTERN
JOMStringToNumberMapper *JOMStringToNumberByFormatter(NSString *dstKey, NSNumberFormatter *formatter);
