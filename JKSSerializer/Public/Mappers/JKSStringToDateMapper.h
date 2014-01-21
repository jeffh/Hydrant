#import "JKSMapper.h"
#import "JKSBase.h"


@interface JKSStringToDateMapper : NSObject <JKSMapper>
@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey dateFormatter:(NSDateFormatter *)dateFormatter;

@end

JKS_EXTERN
JKSStringToDateMapper *JKSStringToDate(NSString *dstKey, NSString *formatString);

JKS_EXTERN
JKSStringToDateMapper *JKSStringToDateWithFormatter(NSString *dstKey, NSDateFormatter *dateFormatter);
