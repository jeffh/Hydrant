#import "JKSError.h"

@interface JKSError (Spec)

+ (instancetype)fatalError;
+ (instancetype)nonFatalError;

@end
