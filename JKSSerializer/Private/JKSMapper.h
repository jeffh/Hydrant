#import "JKSSerializerProtocol.h"

@protocol JKSMapper <NSObject>
- (void)serializeToObject:(id)object
               fromObject:(id)sourceObject
               serializer:(id<JKSSerializer>)serializer;
- (void)deserializeToObject:(id)object
                 fromObject:(id)sourceObject
                 serializer:(id<JKSSerializer>)serializer;
@end