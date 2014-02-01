#import <Foundation/Foundation.h>

/*! A placeholder protocol that is used to indicate which methods
 *  are used by the HYDCollectionMapper, such as HYDMapArrayOf or HYDMapSetOf.
 *
 *  These aren't enforced when passed through to the mapper, but you can
 *  support this interface to ensure you support the required methods in your
 *  own collections.
 *
 *  Reading collections simply requires <HYDMutableCollection> protocol,
 *  where as writing requires this protocol.
 */
@protocol HYDMutableCollection <NSObject>

- (void)addObject:(id)object;

@end
