#import "HYDMapper.h"
#import "HYDBase.h"


@interface HYDFirstMapper : NSObject <HYDMapper>

- (id)initWithMappers:(NSArray *)mappers;

@end


/*! Creates a mapper that runs through all the given mappers sequentially
 *  until one mapper returns a value object (non-fatal error) or all
 *  possible mappers fail.
 *
 *  Reversing this mapper will preserve the same order of mappers, but
 *  reverse each individual mapper.
 *
 *  @param mappers An array of mappers to try.
 *  @returns a mapper that will try each mapper in sequence.
 */
HYD_EXTERN
id<HYDMapper> HYDMapFirstMapperInArray(NSArray *mappers);

/*! Creates a mapper that runs through all the given mappers sequentially
 *  until one mapper returns a value object (non-fatal error) or all
 *  possible mappers fail.
 */
#define HYDMapFirst(...) (HYDMapFirstMapperInArray(@[ __VA_ARGS__ ]))
