#import "JOMObjectFactory.h"

@implementation JOMObjectFactory

- (id)newObjectOfClass:(Class)aClass
{
    id object = [aClass new];
    if ([object conformsToProtocol:@protocol(NSMutableCopying)]) {
        object = [object mutableCopy];
    }
    return object;
}

@end
