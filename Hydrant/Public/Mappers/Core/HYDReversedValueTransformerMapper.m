#import "HYDReversedValueTransformerMapper.h"
#import "HYDError.h"
#import "HYDValueTransformerMapper.h"
#import "HYDIdentityMapper.h"


@interface HYDReversedValueTransformerMapper ()

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) NSValueTransformer *valueTransformer;

@end


@implementation HYDReversedValueTransformerMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)innerMapper valueTransformer:(NSValueTransformer *)valueTransformer
{
    if (![[valueTransformer class] allowsReverseTransformation]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"HYDReversedValueTransformerMapper cannot use value tranformer %@ because it is declared as having no reverse transformation",
                           valueTransformer];
    }

    self = [super init];
    if (self) {
        self.innerMapper = innerMapper;
        self.valueTransformer = valueTransformer;
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    return [self.valueTransformer reverseTransformedValue:sourceObject];
}

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    id<HYDMapper> reversedInnerMapper = [self.innerMapper reverseMapperWithDestinationAccessor:destinationAccessor];
    return [[HYDValueTransformerMapper alloc] initWithMapper:reversedInnerMapper
                                            valueTransformer:self.valueTransformer];
}

- (id<HYDAccessor>)destinationAccessor
{
    return [self.innerMapper destinationAccessor];
}

@end

HYD_EXTERN_OVERLOADED
HYDReversedValueTransformerMapper *HYDMapReverseValue(NSString *destinationKey, NSString *valueTransformerName)
{
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:valueTransformerName];
    if (!transformer) {
        [NSException raise:NSInvalidArgumentException
                    format:@"No transformer found when doing: [NSValueTransformer: valueTransformerForName:@\"%@\"]",
                           valueTransformerName];
    }
    return HYDMapReverseValue(destinationKey, transformer);
}

HYD_EXTERN_OVERLOADED
HYDReversedValueTransformerMapper *HYDMapReverseValue(NSString *destinationKey, NSValueTransformer *valueTransformer)
{
    return [[HYDReversedValueTransformerMapper alloc] initWithMapper:HYDMapIdentity(destinationKey)
                                                    valueTransformer:valueTransformer];
}
