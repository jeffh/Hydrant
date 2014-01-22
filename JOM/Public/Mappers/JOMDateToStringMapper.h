#import "JOMBase.h"
#import "JOMMapper.h"

@interface JOMDateToStringMapper : NSObject <JOMMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey dateFormatter:(NSDateFormatter *)dateFormatter;

@end

JOM_EXTERN
JOMDateToStringMapper *JOMDateToString(NSString *dstKey, NSString *formatString);

JOM_EXTERN
JOMDateToStringMapper *JOMDateToStringWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter);