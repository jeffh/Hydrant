#import <Foundation/Foundation.h>

@interface JKSKeyValueSerializer : NSObject

+ (instancetype)sharedSerializer;
- (void)registerClass:(Class)aClass withMapping:(NSDictionary *)dictionary;

- (void)serializeToObject:(id)object
               fromObject:(id)sourceObject
               nullObject:(id)nullObject;

- (void)deserializeToObject:(id)object
                 fromObject:(id)sourceObject
                 nullObject:(id)nullObject;

@end
