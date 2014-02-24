#import "HYDBlockValueTransformer.h"

@interface HYDBlockValueTransformer ()

@property (copy, nonatomic) id(^blockTransformer)(id value);
@property (copy, nonatomic) id(^reversedBlockTransformer)(id value);

@end

@implementation HYDBlockValueTransformer

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithBlock:(id(^)(id value))block reversedBlock:(id (^)(id))reversedBlock
{
    self = [super init];
    if (self) {
        self.blockTransformer = block;
        self.reversedBlockTransformer = reversedBlock;
    }
    return self;
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return self.blockTransformer(value);
}

- (id)reverseTransformedValue:(id)value
{
    return self.reversedBlockTransformer(value);
}

@end
