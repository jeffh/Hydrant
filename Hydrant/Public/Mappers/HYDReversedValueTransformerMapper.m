#import "HYDReversedValueTransformerMapper.h"
#import "HYDError.h"
#import "HYDValueTransformerMapper.h"


@interface HYDReversedValueTransformerMapper ()
@property(nonatomic, strong) NSValueTransformer *valueTransformer;
@end

@implementation HYDReversedValueTransformerMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey valueTransformer:(NSValueTransformer *)valueTransformer
{
    if (![[valueTransformer class] allowsReverseTransformation]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"HYDReversedValueTransformerMapper cannot use value tranformer %@ because it is declared as having no reverse transformation",
                           valueTransformer];
    }

    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.valueTransformer = valueTransformer;
    }
    return self;
}

#pragma mark - <HYDMapper>

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    return [self.valueTransformer reverseTransformedValue:sourceObject];
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[HYDValueTransformerMapper alloc] initWithDestinationKey:destinationKey
                                                    valueTransformer:self.valueTransformer];
}

@end

HYD_EXTERN
HYD_OVERLOADED
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

HYD_EXTERN
HYD_OVERLOADED
HYDReversedValueTransformerMapper *HYDMapReverseValue(NSString *destinationKey, NSValueTransformer *valueTransformer)
{
    return [[HYDReversedValueTransformerMapper alloc] initWithDestinationKey:destinationKey
                                                            valueTransformer:valueTransformer];
}
