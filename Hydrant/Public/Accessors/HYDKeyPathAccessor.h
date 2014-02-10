#import "HYDBase.h"
#import "HYDAccessor.h"

@interface HYDKeyPathAccessor : NSObject <HYDAccessor>

- (id)initWithKeyPaths:(NSArray *)keyPaths;

@end

HYD_EXTERN
HYDKeyPathAccessor *HYDAccessKeyPathFromArray(NSArray *keyPaths)
HYD_REQUIRE_NON_NIL(1);

#define HYDAccessKeyPath(...) HYDAccessKeyPathFromArray([NSArray arrayWithObjects:__VA_ARGS__, nil])
