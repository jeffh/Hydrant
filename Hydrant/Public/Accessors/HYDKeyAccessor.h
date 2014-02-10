#import "HYDBase.h"
#import "HYDAccessor.h"

@interface HYDKeyAccessor : NSObject <HYDAccessor>

- (id)initWithKeys:(NSArray *)keys;

@end


HYD_EXTERN
HYDKeyAccessor *HYDAccessKeyFromArray(NSArray *fields)
HYD_REQUIRE_NON_NIL(1);

#define HYDAccessKey(...) HYDAccessKeyFromArray([NSArray arrayWithObjects:__VA_ARGS__, nil])
