#import "HYDBase.h"
#import "HYDMapper.h"

@interface HYDDateToStringMapper : NSObject <HYDMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey dateFormatter:(NSDateFormatter *)dateFormatter;

@end

HYD_EXTERN
HYDDateToStringMapper *HYDDateToString(NSString *dstKey, NSString *formatString);

HYD_EXTERN
HYDDateToStringMapper *HYDDateToStringWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter);