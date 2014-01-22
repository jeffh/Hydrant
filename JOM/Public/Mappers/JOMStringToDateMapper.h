#import "JOMMapper.h"
#import "JOMBase.h"


@interface JOMStringToDateMapper : NSObject <JOMMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey dateFormatter:(NSDateFormatter *)dateFormatter;

@end

JOM_EXTERN
JOMStringToDateMapper *JOMStringToDate(NSString *dstKey, NSString *formatString);

JOM_EXTERN
JOMStringToDateMapper *JOMStringToDateWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter);
