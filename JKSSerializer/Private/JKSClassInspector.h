#import <Foundation/Foundation.h>

@interface JKSClassInspector : NSObject

@property (strong, nonatomic, readonly) NSArray *allProperties;
@property (strong, nonatomic, readonly) NSArray *weakProperties;
@property (strong, nonatomic, readonly) NSArray *nonWeakProperties;

+ (instancetype)inspectorForClass:(Class)aClass;
- (id)initWithClass:(Class)aClass;

- (NSString *)descriptionForObject:(id)object
                    withProperties:(NSArray *)properties;

@end
