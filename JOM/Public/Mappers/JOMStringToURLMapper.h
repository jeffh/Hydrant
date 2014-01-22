#import "JOMBase.h"
#import "JOMMapper.h"

@interface JOMStringToURLMapper : NSObject <JOMMapper>
@property (copy, nonatomic) NSString *destinationKey;
@property (copy, nonatomic) NSSet *allowedSchemes;

- (id)initWithDestinationKey:(NSString *)destinationKey;

@end

JOM_EXTERN
JOMStringToURLMapper *JOMStringToURL(NSString *destinationKey);

JOM_EXTERN
JOMStringToURLMapper *JOMStringToURLOfScheme(NSString *destinationKey, NSArray *allowedSchemes);