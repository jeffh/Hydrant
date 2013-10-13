#import "JKSMapper.h"

@interface JKSKVCMapper : NSObject <JKSMapper>

+ (instancetype)mapperWithDSLMapping:(NSDictionary *)dictionary;
- (id)initWithMapping:(NSDictionary *)mapping;

@end
