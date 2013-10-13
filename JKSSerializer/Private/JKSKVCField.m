#import "JKSKVCField.h"

@implementation JKSKVCField

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.name = name;
    }
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)serializeObject:(id)value sourceKey:sourceKeyPath serializer:(id<JKSSerializer>)serializer
{
    return [value valueForKey:sourceKeyPath];
}

- (id)deserializeObject:(id)value serializer:(id<JKSSerializer>)serializer
{
    return [value valueForKey:self.name];
}

- (NSString *)destinationKey
{
    return self.name;
}

@end
