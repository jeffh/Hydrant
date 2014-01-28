#import "HYDIdentityMapper.h"
#import "HYDError.h"


@interface HYDIdentityMapper ()

@property (copy, nonatomic, readwrite) NSString *destinationKey;

@end


@implementation HYDIdentityMapper

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

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    return sourceObject;
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[[self class] alloc] initWithDestinationKey:destinationKey];
}

@end


HYD_EXTERN
id<HYDMapper> HYDMapIdentity(NSString *destinationKey)
{
    return [[HYDIdentityMapper alloc] initWithDestinationKey:destinationKey];
}
