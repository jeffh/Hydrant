#import "HYDReversedValueTransformer.h"


@interface HYDReversedValueTransformer ()

@property (strong, nonatomic) NSValueTransformer *valueTransformer;

@end


@implementation HYDReversedValueTransformer

- (instancetype)initWithValueTransformer:(NSValueTransformer *)valueTransformer
{
    if (![[valueTransformer class] allowsReverseTransformation]) {
        [NSException raise:NSInvalidArgumentException format:@"Provided value transformer (%@) does not support reverse transformations",
         NSStringFromClass([valueTransformer class])];
    }

    self = [super init];
    if (self) {
        self.valueTransformer = valueTransformer;
    }
    return self;
}

- (id)transformedValue:(id)value
{
    return [self.valueTransformer reverseTransformedValue:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [self.valueTransformer transformedValue:value];
}

@end
