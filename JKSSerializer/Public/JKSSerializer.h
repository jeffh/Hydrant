#import <Foundation/Foundation.h>

@interface JKSSerializer : NSObject

@property (strong, nonatomic) id nullObject;

+ (instancetype)sharedSerializer;
- (void)registerClass:(Class)aClass withMapping:(NSDictionary *)dictionary;
- (void)registerClass:(Class)aClass withDeserializationMapping:(NSDictionary *)dictionary;
- (void)registerClass:(Class)aClass withSerializationMapping:(NSDictionary *)dictionary;

- (void)serializeToObject:(id)object
               fromObject:(id)sourceObject;

- (void)deserializeToObject:(id)object
                 fromObject:(id)sourceObject;

@end
