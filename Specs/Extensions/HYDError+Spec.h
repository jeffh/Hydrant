#import "HYDError.h"

@interface HYDError (Spec)

+ (instancetype)fatalError;
+ (instancetype)nonFatalError;

@end
