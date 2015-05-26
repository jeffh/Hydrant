#import <Hydrant/Hydrant.h>

@interface HYDError (Spec)

+ (instancetype)fatalError;
+ (instancetype)nonFatalError;
+ (instancetype)dummyError;

@end
