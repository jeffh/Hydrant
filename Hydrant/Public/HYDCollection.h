#import <Foundation/Foundation.h>

/*! A protocol that is used to indicate which methods are used by the HYDCollectionMapper,
 *  such as HYDMapArrayOf or HYDMapSetOf.
 *
 *  These are enforced when passed to the HYDCollectionMapper.
 *
 *  Reading collections requires this protocol, writing requires
 *  methods on the <HYDMutableCollection> protocol.
 *
 *  @see HYDMutableCollection
 *  @see HYDCollectionMapper
 */
@protocol HYDCollection <NSFastEnumeration>
@end

@interface NSArray (HYDCollection) <HYDCollection>
@end

@interface NSHashTable (HYDCollection) <HYDCollection>
@end

@interface NSSet (HYDCollection) <HYDCollection>
@end

@interface NSOrderedSet (HYDCollection) <HYDCollection>
@end
