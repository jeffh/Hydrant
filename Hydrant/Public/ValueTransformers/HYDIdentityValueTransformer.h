#import <Foundation/Foundation.h>

/*! A value transformer that simply returns the value it receives.
 *
 *  This provides a useful default value transformer for places in
 *  Hydrant that require a value transformer.
 */
@interface HYDIdentityValueTransformer : NSValueTransformer

@end
