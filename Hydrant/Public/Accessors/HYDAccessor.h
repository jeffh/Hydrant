#import "HYDBase.h"

@class HYDError;

@protocol HYDAccessor <NSObject, NSCopying>

- (NSArray *)valuesFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error;
- (HYDError *)setValues:(NSArray *)values ofClasses:(NSArray *)destinationClasses onObject:(id)destinationObject;
- (NSArray *)fieldNames;

@end
