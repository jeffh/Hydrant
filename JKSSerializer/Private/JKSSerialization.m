#import "JKSSerialization.h"
#import "JKSClassInspector.h"

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

- (BOOL)canDeserializeObject:(id)srcObject withClassHint:(Class)dstClass
{
    if (dstClass) {
        return [dstClass isSubclassOfClass:self.destinationClass] && [srcObject isKindOfClass:self.sourceClass];
    } else if ([[srcObject class] isSubclassOfClass:self.sourceClass]) {
        NSSet *srcKeys = [NSSet setWithArray:[self propertiesForObject:srcObject]];
        NSSet *dstKeys = [NSSet setWithArray:self.mapping.allKeys];
        return [dstKeys isSubsetOfSet:srcKeys];
    }
    return NO;
}

- (NSArray *)propertiesForObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [object allKeys];
    }
    JKSClassInspector *inspector = [JKSClassInspector inspectorForClass:[object class]];
    return [inspector.allProperties valueForKey:@"name"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p %@ -> %@> %@",
            NSStringFromClass([self class]), self, self.sourceClass, self.destinationClass, self.mapping];
}

@end

