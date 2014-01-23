#import "HYDBase.h"
#import "HYDMapper.h"


@interface HYDStringToURLMapper : NSObject <HYDMapper>

@property (copy, nonatomic) NSString *destinationKey;
@property (copy, nonatomic) NSSet *allowedSchemes;

- (id)initWithDestinationKey:(NSString *)destinationKey;

@end


HYD_EXTERN
HYDStringToURLMapper *HYDStringToURL(NSString *destinationKey);

HYD_EXTERN
HYDStringToURLMapper *HYDStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes);