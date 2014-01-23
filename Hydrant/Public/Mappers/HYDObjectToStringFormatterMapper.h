#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDObjectToStringFormatterMapper : NSObject <HYDMapper>
@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) NSFormatter *formatter;

- (id)initWithDestinationKey:(NSString *)destinationKey formatter:(NSFormatter *)formatter;

@end

HYD_EXTERN
HYDObjectToStringFormatterMapper *HYDObjectToStringWithFormatter(NSString *destinationKey, NSFormatter *formatter);