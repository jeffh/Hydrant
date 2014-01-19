#import <Foundation/Foundation.h>

@protocol JKSMutableCollection <NSFastEnumeration>

- (void)addObject:(id)object;

@end


@interface NSMutableArray (JKSMutableCollectionInterface) <JKSMutableCollection>
@end
@interface NSMutableSet (JKSMutableCollectionInterface) <JKSMutableCollection>
@end
@interface NSHashTable (JKSMutableCollectionInterface) <JKSMutableCollection>
@end
@interface NSOrderedSet (JKSMutableCollectionInterface) <JKSMutableCollection>
@end