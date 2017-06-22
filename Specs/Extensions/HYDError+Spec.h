#import <Hydrant/Hydrant.h>
#import "HYDSCedarMatchers.h"

@interface HYDError (Spec)

+ (instancetype)fatalError;
+ (instancetype)nonFatalError;
+ (instancetype)dummyError;

@end
