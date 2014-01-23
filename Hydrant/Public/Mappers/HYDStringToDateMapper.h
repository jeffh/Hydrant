#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDStringToDateMapper : NSObject <HYDMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey dateFormatter:(NSDateFormatter *)dateFormatter;

@end

HYD_EXTERN
HYDStringToDateMapper *HYDStringToDate(NSString *dstKey, NSString *formatString);

HYD_EXTERN
HYDStringToDateMapper *HYDStringToDateWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter);
