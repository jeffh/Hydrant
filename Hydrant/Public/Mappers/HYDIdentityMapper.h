#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDIdentityMapper : NSObject <HYDMapper>

@property (strong, nonatomic) NSString *destinationKey;

- (id)initWithDestinationKey:(NSString *)destinationKey;

@end


/*! A mapper that just returns the value it was given.
 *
 *  This is used internally by more complex mappers as a default
 *  mapper for ones not explicitly defined in their constructor syntax.
 *  A perfect example is the values of HYDKeyValueMapper's dictionary mapping.
 *
 *  @param destinationKey the property hint to the parent mapper to indicate where to place the returned value.
 *  @returns a mapper that returns any value its given.
 *
 *  @see HYDKeyValueMapper
 */
HYD_EXTERN
HYDIdentityMapper *HYDMapIdentity(NSString *destinationKey);