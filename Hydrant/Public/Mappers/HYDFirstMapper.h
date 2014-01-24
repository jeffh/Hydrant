#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDFirstMapper : NSObject <HYDMapper>

- (id)initWithMappers:(NSArray *)mappers;

@end


/*! Creates a mapper that runs through all the given mappers sequentially
 *  until one mapper returns a value object (non-fatal error) or all
 *  possible mappers fail.
 *
 *  @param mappers An array of mappers to try.
 *  @returns a mapper that will try each mapper in sequence.
 */
HYD_EXTERN
HYDFirstMapper *HYDMapFirstInMapperArray(NSArray *mappers);

/*! Creates a mapper that runs through all the given mappers sequentially
 *  until one mapper returns a value object (non-fatal error) or all
 *  possible mappers fail.
 */
#define HYDMapFirst(...) (HYDMapFirstInMapperArray(@[ __VA_ARGS__ ]))
