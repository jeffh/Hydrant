#import "HYDObjectFactory.h"

@implementation HYDObjectFactory

- (id)newObjectOfClass:(Class)aClass
{
    id object = [aClass new];
    if ([object conformsToProtocol:@protocol(NSMutableCopying)]) {
        object = [object mutableCopy];
    }
    return object;
}

@end
