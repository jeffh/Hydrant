#import "JKSSerializerProtocol.h"

@protocol JKSProcessor <NSObject>

- (id)serializeObject:(id)value sourceKey:sourceKeyPath serializer:(id<JKSSerializer>)serializer;
- (id)deserializeObject:(id)value serializer:(id<JKSSerializer>)serializer;
- (NSString *)destinationKey;

@end
