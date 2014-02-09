#import "HYDBase.h"
#import "HYDAccessor.h"

@interface HYDKeyPathAccessor : NSObject <HYDAccessor>

- (id)initWithKeyPaths:(NSArray *)keyPaths;

@end

HYD_EXTERN
HYD_OVERLOADED
HYDKeyPathAccessor *HYDAccessKeyPath(NSString *keyPath)
HYD_REQUIRE_NON_NIL(1);


HYD_EXTERN
HYD_OVERLOADED
HYDKeyPathAccessor *HYDAccessKeyPath(NSArray *keyPaths)
HYD_REQUIRE_NON_NIL(1);
