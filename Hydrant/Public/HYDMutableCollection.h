#import <Foundation/Foundation.h>

@protocol HYDMutableCollection<NSFastEnumeration>

- (void)addObject:(id)object;

@end


@interface NSMutableArray (JOMMutableCollectionInterface) <HYDMutableCollection>
@end
@interface NSMutableSet (JOMMutableCollectionInterface) <HYDMutableCollection>
@end
@interface NSHashTable (JOMMutableCollectionInterface) <HYDMutableCollection>
@end
@interface NSOrderedSet (JOMMutableCollectionInterface) <HYDMutableCollection>
@end