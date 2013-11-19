#import "JKSBase.h"
#import "JKSMapper.h"

@interface JKSNumberMapper : NSObject <JKSMapper>

@property (strong, nonatomic) NSString *destinationKey;
@property (assign, nonatomic) BOOL convertsToString;

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter;

@end

JKS_EXTERN
JKSNumberMapper* JKSNumberStyle(NSString *destKey, NSNumberFormatterStyle numberFormatStyle);
