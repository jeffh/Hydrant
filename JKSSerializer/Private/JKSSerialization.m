#import "JKSSerialization.h"

@implementation JKSSerialization

- (id)initWithSourceClass:(Class)srcClass destinationClass:(Class)dstClass mapping:(NSDictionary *)mapping
{
    self = [super init];
    if (self) {
        self.sourceClass = srcClass;
        self.destinationClass = dstClass;
        self.mapping = mapping;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p %@ -> %@> %@",
            NSStringFromClass([self class]), self, self.sourceClass, self.destinationClass, self.mapping];
}

@end

