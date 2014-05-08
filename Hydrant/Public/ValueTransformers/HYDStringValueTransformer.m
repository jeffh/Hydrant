#import "HYDStringValueTransformer.h"


@implementation HYDStringValueTransformer

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if ([[NSNull null] isEqual:value]) {
        return nil;
    }
    return [value description];
}

@end
