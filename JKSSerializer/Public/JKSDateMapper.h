#import "JKSBase.h"
#import "JKSMapper.h"

@interface JKSDateMapper : NSObject <JKSMapper>
@property (strong, nonatomic) NSString *destinationKey;
@property (assign, nonatomic) BOOL convertsToDate;

- (id)initWithDestinationKey:(NSString *)destinationKey dateFormatter:(NSDateFormatter *)dateFormatter;

@end

JKS_EXTERN
JKSDateMapper* JKSDate(NSString *dstKey, NSString *formatString);
