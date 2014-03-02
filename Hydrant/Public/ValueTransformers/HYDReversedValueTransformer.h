#import <Foundation/Foundation.h>

/*! This value transformer reverses the given value transformer.
 *
 *  Calling transformValue: on this transformer will call reverseTransformedValue: on
 *  the inner value transformer.
 *
 *  Similarly, calling reverseTransformedValue: on this transformer will call
 *  transformValue: on the inner value transformer.
 *
 *  This is useful to use the reverse transform of a value transformer without having to
 *  explicitly call that method in an implementation that accepts value transformers.
 */
@interface HYDReversedValueTransformer : NSValueTransformer

/*! Constructs a new value transformer that inverts the reverseTransformedValue and transformValue
 *  invocations of the given value transformer.
 *
 *  @param valueTransformer The instance of the value transformer to reverse. It must be reverseable.
 */
- (id)initWithValueTransformer:(NSValueTransformer *)valueTransformer;

@end
