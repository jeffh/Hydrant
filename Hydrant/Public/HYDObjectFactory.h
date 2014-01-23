#import "HYDFactory.h"

@interface HYDObjectFactory : NSObject <HYDFactory>

+ (instancetype)factoryOrDefault:(id<HYDFactory>)factory;

@end
