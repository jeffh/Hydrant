#import <Foundation/Foundation.h>

/*! A value transformer that uses the blocks its provided to do value transformations.
 *
 *  Due to the nature of NSValueTransformer interface, HYDBlockValueTransformers are
 *  always reversable.
 */
@interface HYDBlockValueTransformer : NSValueTransformer

- (id)initWithBlock:(id(^)(id value))block reversedBlock:(id(^)(id value))reversedBlock;

@end
