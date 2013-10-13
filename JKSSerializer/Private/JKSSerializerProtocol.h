#import <Foundation/Foundation.h>

@protocol JKSSerializer <NSObject>

- (id)nullObject;
- (BOOL)isNullObject:(id)object;

- (void)serializeToObject:(id)object fromObject:(id)sourceObject;
- (void)deserializeToObject:(id)object fromObject:(id)sourceObject;

- (id)serializeObjectOfClass:(Class)aClass fromSourceObject:(id)sourceObject;
- (id)deserializeObjectOfClass:(Class)aClass fromSourceObject:(id)sourceObject;

@end
