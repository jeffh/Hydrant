#import "HYDValueTransformerMapper.h"
#import "HYDError.h"
#import "HYDReversedValueTransformerMapper.h"
#import "HYDThreadMapper.h"


@interface HYDValueTransformerMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSValueTransformer *valueTransformer;

- (id)initWithValueTransformer:(NSValueTransformer *)valueTransformer;

@end


@implementation HYDValueTransformerMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithValueTransformer:(NSValueTransformer *)valueTransformer
{
    self = [super init];
    if (self) {
        self.valueTransformer = valueTransformer;
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>",
            NSStringFromClass(self.class),
            self.valueTransformer];
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    return [self.valueTransformer transformedValue:sourceObject];
}

- (id<HYDMapper>)reverseMapper
{
    return HYDMapReverseValue(self.valueTransformer);
}

@end

HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(id<HYDMapper> mapper, NSValueTransformer *valueTransformer)
{
    return HYDMapThread(mapper, HYDMapValue(valueTransformer));
}

HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(id<HYDMapper> mapper, NSString *valueTransformerName)
{
    return HYDMapThread(mapper, HYDMapValue(valueTransformerName));
}

HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSString *valueTransformerName)
{
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:valueTransformerName];
    if (!transformer) {
        [NSException raise:NSInvalidArgumentException
                    format:@"No transformer found when doing: [NSValueTransformer: valueTransformerForName:@\"%@\"]",
         valueTransformerName];
    }
    return HYDMapValue(transformer);
}

HYD_EXTERN_OVERLOADED
HYDValueTransformerMapper *HYDMapValue(NSValueTransformer *valueTransformer)
{
    return [[HYDValueTransformerMapper alloc] initWithValueTransformer:valueTransformer];
}
