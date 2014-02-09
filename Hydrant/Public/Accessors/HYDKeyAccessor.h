#import "HYDBase.h"
#import "HYDAccessor.h"

@interface HYDKeyAccessor : NSObject <HYDAccessor>

- (id)initWithKeys:(NSArray *)keys;

@end


HYD_EXTERN
HYD_OVERLOADED
HYDKeyAccessor *HYDAccessKey(NSString *fieldName)
HYD_REQUIRE_NON_NIL(1);


HYD_EXTERN
HYD_OVERLOADED
HYDKeyAccessor *HYDAccessKey(NSArray *fields)
HYD_REQUIRE_NON_NIL(1);
