#import <Foundation/Foundation.h>

@protocol JOMMutableCollection<NSFastEnumeration>

- (void)addObject:(id)object;

@end


@interface NSMutableArray (JOMMutableCollectionInterface) <JOMMutableCollection>
@end
@interface NSMutableSet (JOMMutableCollectionInterface) <JOMMutableCollection>
@end
@interface NSHashTable (JOMMutableCollectionInterface) <JOMMutableCollection>
@end
@interface NSOrderedSet (JOMMutableCollectionInterface) <JOMMutableCollection>
@end