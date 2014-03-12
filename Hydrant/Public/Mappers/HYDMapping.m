#import "HYDMapping.h"
#import "HYDMapper.h"
#import "HYDAccessor.h"
#import "HYDDefaultAccessor.h"


@interface HYDMapping : NSObject <HYDMapping>

@property (strong, nonatomic) id<HYDMapper> mapper;
@property (strong, nonatomic) id<HYDAccessor> accessor;

- (instancetype)initWithMapper:(id<HYDMapper>)mapper accessor:(id<HYDAccessor>)accessor;

@end

@implementation HYDMapping

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithMapper:(id<HYDMapper>)mapper accessor:(id<HYDAccessor>)accessor
{
    self = [super init];
    if (self) {
        self.mapper = mapper;
        self.accessor = accessor;
    }
    return self;
}

#pragma mark - <NSObject>

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return [other isKindOfClass:[self class]] && [self.mapper isEqual:[other mapper]] && [self.accessor isEqual:[other mapper]];
    }
}

- (NSUInteger)hash
{
    return self.mapper.hash ^ self.accessor.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ map %@ to %@>", NSStringFromClass([self class]), self.mapper, self.accessor];
}

@end

HYD_EXTERN_OVERLOADED
HYDMapping *HYDMap(id<HYDMapper> mapper, NSString *destinationKey)
{
    return [[HYDMapping alloc] initWithMapper:mapper accessor:HYDAccessDefault(destinationKey)];
}

HYD_EXTERN_OVERLOADED
HYDMapping *HYDMap(id<HYDMapper> mapper, id<HYDAccessor> accessor)
{
    return [[HYDMapping alloc] initWithMapper:mapper accessor:accessor];
}
