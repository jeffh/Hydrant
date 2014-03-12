#import "HYDValueTransformerMapper.h"
#import "HYDError.h"
#import "HYDReversedValueTransformerMapper.h"
#import "HYDIdentityMapper.h"


@interface HYDValueTransformerMapper ()

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) NSValueTransformer *valueTransformer;

@end


@implementation HYDValueTransformerMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)innerMapper valueTransformer:(NSValueTransformer *)valueTransformer
{
    self = [super init];
    if (self) {
        self.innerMapper = innerMapper;
        self.valueTransformer = valueTransformer;
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@ with %@>",
            NSStringFromClass(self.class),
            self.valueTransformer,
            self.innerMapper];
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    return [self.valueTransformer transformedValue:sourceObject];
}

- (id<HYDMapper>)reverseMapper
{
    id<HYDMapper> reversedInnerMapper = [self.innerMapper reverseMapper];
    return [[HYDReversedValueTransformerMapper alloc] initWithMapper:reversedInnerMapper
                                                    valueTransformer:self.valueTransformer];
}

@end

HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(id<HYDMapper> mapper, NSValueTransformer *valueTransformer)
{
    return [[HYDValueTransformerMapper alloc] initWithMapper:mapper
                                            valueTransformer:valueTransformer];
}

HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(id<HYDMapper> mapper, NSString *valueTransformerName)
{
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:valueTransformerName];
    if (!transformer) {
        [NSException raise:NSInvalidArgumentException
                    format:@"No transformer found when doing: [NSValueTransformer: valueTransformerForName:@\"%@\"]",
                           valueTransformerName];
    }
    return HYDMapValue(mapper, transformer);
}

HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *valueTransformerName)
{
    return HYDMapValue(HYDMapIdentity(), valueTransformerName);
}

HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSValueTransformer *valueTransformer)
{
    return HYDMapValue(HYDMapIdentity(), valueTransformer);
}
