#import "HYDValueTransformerMapper.h"
#import "HYDError.h"
#import "HYDReversedValueTransformerMapper.h"
#import "HYDKeyAccessor.h"


@interface HYDValueTransformerMapper ()

@property (strong, nonatomic) id<HYDAccessor> destinationAccessor;
@property (strong, nonatomic) NSValueTransformer *valueTransformer;

@end


@implementation HYDValueTransformerMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor valueTransformer:(NSValueTransformer *)valueTransformer
{
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
    return [self.valueTransformer transformedValue:sourceObject];
}

- (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor
{
    return [[HYDReversedValueTransformerMapper alloc] initWithDestinationAccessor:destinationAccessor
                                                                 valueTransformer:self.valueTransformer];
}

@end


HYD_EXTERN_OVERLOADED
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

HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *destinationKey, NSValueTransformer *valueTransformer)
{
    return [[HYDValueTransformerMapper alloc] initWithDestinationAccessor:HYDAccessKey(destinationKey)
                                                         valueTransformer:valueTransformer];
}
