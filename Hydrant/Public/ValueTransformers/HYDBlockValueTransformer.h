#import <Foundation/Foundation.h>

@interface HYDBlockValueTransformer : NSValueTransformer

- (id)initWithBlock:(id(^)(id value))block reversedBlock:(id(^)(id value))reversedBlock;

@end
