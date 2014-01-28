#import "HYDBase.h"

/*! A constant that provides a convenient way to set a NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "2014-01-14T14:35:23-0800"
 *
 *  The value is:
 *
 *     NSString *HYDRFC3339DateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
 *
 */
HYD_EXTERN NSString *HYDRFC3339DateFormat;

/*! A constant that is used to visually indicate the Root of a mapper hierarchy.
 *
 *  This should be used in placed of a destination key:
 *
 *     id<HYDMapper> mapper = HYDMapObject(HYDRootMapper, ...);
 *
 */
HYD_EXTERN id HYDRootMapper;
