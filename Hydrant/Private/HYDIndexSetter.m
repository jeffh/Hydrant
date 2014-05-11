#import "HYDIndexSetter.h"
#import "HYDError.h"


@interface HYDIndexSetter ()

@property (nonatomic, copy) HYDIndexSetterFillerBlock fillerFactory;

@end


@implementation HYDIndexSetter

- (instancetype)init
{
    return [self initWithFillerFactory:^id{ return nil; }];
}

- (instancetype)initWithFillerFactory:(HYDIndexSetterFillerBlock)factory
{
    self = [super init];
    if (self) {
        self.fillerFactory = factory;
    }
    return self;
}

- (HYDError *)setValue:(id)value atIndex:(NSUInteger)index inObject:(id)containerObject
{
    while ([containerObject count] <= index) {
        [containerObject addObject:self.fillerFactory() ?: [NSNull null]];
    }
    [containerObject setObject:value ?: [NSNull null] atIndex:index];
    return nil;
}

@end
