#import <Foundation/Foundation.h>


@class HYDError;

typedef id(^HYDIndexSetterFillerBlock)();


@interface HYDIndexSetter : NSObject

- (instancetype)init;
- (instancetype)initWithFillerFactory:(HYDIndexSetterFillerBlock)factory;
- (HYDError *)setValue:(id)value atIndex:(NSUInteger)index inObject:(id)containerObject;

@end
