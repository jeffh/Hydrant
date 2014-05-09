#import "HYDBase.h"
#import "HYDMapper.h"

@class HYDURLFormatter;


@interface HYDObjectToStringFormatterMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper formatter:(NSFormatter *)formatter;

@end

/*! Constructs a mapper that utilizes the NSFormatter to convert the source object to a string.
 *
 *  @param formatter the NSFormatter to use for converting the source object into a string.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObjectToStringByFormatter(NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that utilizes the NSFormatter to convert the source object to a string.
 *
 *  @param mapper The mapper that processes the source value before this mapper.
 *  @param formatter the NSFormatter to use for converting the source object into a string.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapObjectToStringByFormatter(id<HYDMapper> mapper, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);
