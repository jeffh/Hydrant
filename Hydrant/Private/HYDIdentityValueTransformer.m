#import "HYDIdentityValueTransformer.h"

@implementation HYDIdentityValueTransformer

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return value;
}

- (id)reverseTransformedValue:(id)value
{
    return value;
}

@end
