#import "JOMError.h"

@interface JOMError (Spec)

+ (instancetype)fatalError;
+ (instancetype)nonFatalError;

@end
