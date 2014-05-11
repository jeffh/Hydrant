#import "HYDBlockValueTransformer.h"

@interface HYDBlockValueTransformer ()

@property (copy, nonatomic) id(^blockTransformer)(id value);
@property (copy, nonatomic) id(^reversedBlockTransformer)(id value);

@end

@implementation HYDBlockValueTransformer

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithBlock:(id(^)(id value))block reversedBlock:(id (^)(id))reversedBlock
{
    self = [super init];
    if (self) {
        self.blockTransformer = block;
        self.reversedBlockTransformer = reversedBlock;
    }
    return self;
}

- (id)transformedValue:(id)value
{
    if (self.blockTransformer) {
        return self.blockTransformer(value);
    } else {
        return nil;
    }
}

- (id)reverseTransformedValue:(id)value
{
    if (self.reversedBlockTransformer) {
        return self.reversedBlockTransformer(value);
    } else {
        return nil;
    }
}

@end
