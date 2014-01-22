#import <Foundation/Foundation.h>

@interface JOMSerialization : NSObject

@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;
@property (strong, nonatomic) NSDictionary *mapping;

- (id)initWithSourceClass:(Class)srcClass destinationClass:(Class)dstClass mapping:(NSDictionary *)mapping;
- (BOOL)canDeserializeObject:(id)srcObject withClassHint:(Class)dstClass;

@end
