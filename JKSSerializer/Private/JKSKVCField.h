#import "JKSProcessor.h"

@interface JKSKVCField : NSObject <JKSProcessor>

@property (strong, nonatomic) NSString *name;

- (id)initWithName:(NSString *)name;

@end
