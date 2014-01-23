#import "HYDObjectFactory.h"

@implementation HYDObjectFactory

+ (instancetype)factoryOrDefault:(id<HYDFactory>)factory
{
    return factory ?: [[HYDObjectFactory alloc] init];
}

- (id)newObjectOfClass:(Class)aClass
{
    id object = [aClass new];
    if ([object conformsToProtocol:@protocol(NSMutableCopying)]) {
        object = [object mutableCopy];
    }
    return object;
}

@end
