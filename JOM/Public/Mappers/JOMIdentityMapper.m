#import "JOMIdentityMapper.h"

@implementation JOMIdentityMapper

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

#pragma mark - <JOMMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing JOMError **)error
{
    return sourceObject;
}

- (void)setupAsChildMapperWithMapper:(id<JOMMapper>)mapper factory:(id<JOMFactory>)factory
{
}

- (id<JOMMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[[self class] alloc] initWithDestinationKey:destinationKey];
}

@end


JOM_EXTERN
JOMIdentityMapper *JOMIdentity(NSString *destinationKey)
{
    return [[JOMIdentityMapper alloc] initWithDestinationKey:destinationKey];
}