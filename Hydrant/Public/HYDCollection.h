#import <Foundation/Foundation.h>

/*! A placeholder protocol that is used to indicate which methods
 *  are used by the HYDCollectionMapper, such as HYDMapArrayOf or HYDMapSetOf.
 *
 *  These aren't enforced when passed through to the HYDCollectionMapper,
 *  but you can support this interface to ensure you support the required
 *  methods in your own collections.
 *
 *  Reading collections requires this protocol, writing requires
 *  <HYDMutableCollection> protocol.
 *
 *  @see HYDMutableCollection
 *  @see HYDCollectionMapper
 */
@protocol HYDCollection <NSFastEnumeration>
@end
