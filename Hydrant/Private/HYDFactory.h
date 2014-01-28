#import <Foundation/Foundation.h>


@protocol HYDFactory<NSObject>

- (id)newObjectOfClass:(Class)aClass;

@end
