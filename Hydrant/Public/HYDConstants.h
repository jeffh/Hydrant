#import "HYDBase.h"

/*! A constant that provides a convenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "2014-01-14T14:35:23-0800"
 *
 *  The value is:
 *
 *     NSString *HYDRFC3339DateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
 *
 */
HYD_EXTERN NSString *HYDDateFormatRFC3339;

/*! A constant that is used to visually indicate the root of a mapper hierarchy.
 *
 *  This should be used in placed of a destination key:
 *
 *     id<HYDMapper> mapper = HYDMapObject(HYDRootMapper, ...);
 *
 */
HYD_EXTERN id HYDRootMapper;
