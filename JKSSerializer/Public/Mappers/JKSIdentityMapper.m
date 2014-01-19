#import "JKSIdentityMapper.h"

@implementation JKSIdentityMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey {
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
    }
    return self;
}

#pragma mark - <JKSMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing NSError **)error
{
    return sourceObject;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[[self class] alloc] initWithDestinationKey:destinationKey];
}

@end

JKS_EXTERN
JKSIdentityMapper *JKSIdentity(NSString *destinationKey)
{
    return [[JKSIdentityMapper alloc] initWithDestinationKey:destinationKey];
}