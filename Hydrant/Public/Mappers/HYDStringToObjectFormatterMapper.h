#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDStringToObjectFormatterMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) NSFormatter *formatter;

- (id)initWithDestinationKey:(NSString *)destinationKey formatter:(NSFormatter *)formatter;

@end


HYD_EXTERN
HYDStringToObjectFormatterMapper *HYDStringToObjectWithFormatter(NSString *destinationKey, NSFormatter *formatter);