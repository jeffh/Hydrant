#import "HYDReversedValueTransformerMapper.h"
#import "HYDError.h"
#import "HYDValueTransformerMapper.h"
#import "HYDKeyAccessor.h"


@interface HYDReversedValueTransformerMapper ()

@property (strong, nonatomic) id<HYDAccessor> destinationAccessor;
@property (strong, nonatomic) NSValueTransformer *valueTransformer;

@end


@implementation HYDReversedValueTransformerMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor valueTransformer:(NSValueTransformer *)valueTransformer
{
    if (![[valueTransformer class] allowsReverseTransformation]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"HYDReversedValueTransformerMapper cannot use value tranformer %@ because it is declared as having no reverse transformation",
                           valueTransformer];
    }

    self = [super init];
    if (self) {
        self.destinationAccessor = destinationAccessor;
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
    return [[HYDValueTransformerMapper alloc] initWithDestinationAccessor:destinationAccessor
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
    return [[HYDReversedValueTransformerMapper alloc] initWithDestinationAccessor:HYDAccessKey(destinationKey)
                                                                 valueTransformer:valueTransformer];
}
