#import "JKSBase.h"
#import "JKSMapper.h"

@interface JKSDateToStringMapper : NSObject <JKSMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey dateFormatter:(NSDateFormatter *)dateFormatter;

@end

JKS_EXTERN
JKSDateToStringMapper *JKSDateToString(NSString *dstKey, NSString *formatString);

JKS_EXTERN
JKSDateToStringMapper *JKSDateToStringWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter);