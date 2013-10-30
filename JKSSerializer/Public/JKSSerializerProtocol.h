#import <Foundation/Foundation.h>

@protocol JKSSerializer <NSObject>

- (id)objectFromObject:(id)srcObject;
- (id)objectOfClass:(Class)dstClass fromObject:(id)srcObject;

- (id)newObjectOfClass:(Class)aClass;

@end