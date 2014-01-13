#import <Foundation/Foundation.h>


@protocol JKSFactory <NSObject>

- (id)newObjectOfClass:(Class)aClass;

@end