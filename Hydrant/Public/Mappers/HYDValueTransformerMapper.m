#import "HYDValueTransformerMapper.h"
#import "HYDError.h"
#import "HYDReversedValueTransformerMapper.h"


@interface HYDValueTransformerMapper ()
@property(nonatomic, strong) NSValueTransformer *valueTransformer;
@end

@implementation HYDValueTransformerMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationKey:(NSString *)destinationKey valueTransformer:(NSValueTransformer *)valueTransformer
{
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
    return [self.valueTransformer transformedValue:sourceObject];
}

- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[HYDReversedValueTransformerMapper alloc] initWithDestinationKey:destinationKey
                                                            valueTransformer:self.valueTransformer];
}

@end


HYD_EXTERN
HYD_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *destinationKey, NSString *valueTransformerName)
{
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:valueTransformerName];
    if (!transformer) {
        [NSException raise:NSInvalidArgumentException
                    format:@"No transformer found when doing: [NSValueTransformer: valueTransformerForName:@\"%@\"]",
                        valueTransformerName];
    }
    return HYDMapValue(destinationKey, transformer);
}

HYD_EXTERN
HYD_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *destinationKey, NSValueTransformer *valueTransformer)
{
    return [[HYDValueTransformerMapper alloc] initWithDestinationKey:destinationKey valueTransformer:valueTransformer];
}
