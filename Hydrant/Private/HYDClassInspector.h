#import <Foundation/Foundation.h>


@interface HYDClassInspector : NSObject

@property (strong, nonatomic, readonly) NSArray *allProperties;

+ (instancetype)inspectorForClass:(Class)aClass;
+ (void)clearInstanceCache;
- (id)initWithClass:(Class)aClass;

@end
