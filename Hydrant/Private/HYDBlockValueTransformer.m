#import "HYDBlockValueTransformer.h"

@interface HYDBlockValueTransformer ()

@property (copy, nonatomic) id(^blockTransformer)(id value);

@end

@implementation HYDBlockValueTransformer

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithBlock:(id(^)(id value))block
{
    self = [super init];
    if (self) {
        self.blockTransformer = block;
    }
    return self;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return self.blockTransformer(value);
}

@end
