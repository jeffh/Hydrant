#import <Foundation/Foundation.h>

@protocol JKSSerializer;

@protocol JKSMapper <NSObject>

- (NSString *)destinationKey;
- (id)objectFromSourceObject:(id)sourceObject serializer:(id<JKSSerializer>)serializer;
- (instancetype)reverseMapperWithDestinationKey:(NSString *)destinationKey;

@end
