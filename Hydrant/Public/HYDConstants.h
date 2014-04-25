#import "HYDBase.h"

/*! A constant that provides a convenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "2014-01-14T14:35:23-0800"
 */
HYD_EXTERN NSString *HYDDateFormatRFC3339;

/*! A constant that provides a convenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "2014-01-14T14:35:23.456-0800"
 */
HYD_EXTERN NSString *HYDDateFormatRFC3339_milliseconds;

/*! A constant that provides a covenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "Tue, 14 Jan 2014 14:35:32 GMT"
 */
HYD_EXTERN NSString *HYDDateFormatRFC822_day_seconds_gmt;

/*! A constant that provides a covenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "Tue, 14 Jan 2014 14:35 GMT"
 */
HYD_EXTERN NSString *HYDDateFormatRFC822_day_gmt;

/*! A constant that provides a covenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "Tue, 14 Jan 2014 14:35:32"
 */
HYD_EXTERN NSString *HYDDateFormatRFC822_day_seconds;

/*! A constant that provides a covenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "Tue, 14 Jan 2014 14:35"
 */
HYD_EXTERN NSString *HYDDateFormatRFC822_day;

/*! A constant that provides a covenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "14 Jan 2014 14:35:32 GMT"
 */
HYD_EXTERN NSString *HYDDateFormatRFC822_seconds_gmt;

/*! A constant that provides a covenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "14 Jan 2014 14:35 GMT"
 */
HYD_EXTERN NSString *HYDDateFormatRFC822_gmt;

/*! A constant that provides a covenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "14 Jan 2014 14:35:32"
 */
HYD_EXTERN NSString *HYDDateFormatRFC822_seconds;

/*! A constant that provides a covenient way to set an NSDateFormatter style.
 *
 *  It emits and parses datetimes in this style: "14 Jan 2014 14:35"
 */
HYD_EXTERN NSString *HYDDateFormatRFC822;

/*! A constant that is used to visually indicate the root of a mapper hierarchy.
 *
 *  This should be used in placed of a destination:
 *
 *     id<HYDMapper> mapper = HYDMapObject(HYDRootMapper, ...);
 *
 *  @warning Deprecated. Do not use anymore.
 *
 */
DEPRECATED_ATTRIBUTE HYD_EXTERN id HYDRootMapper;

/*! The error domain that all Hydrant mappers emit.
 */
HYD_EXTERN NSString *HYDErrorDomain;

typedef NS_ENUM(NSInteger, HYDErrorCode) {
    /*! The code that indicates the incoming source object was invalid or a partial
     *  parse error occurred. For mappers that check types, HYDErrorInvalidSourceObjectType
     *  may be returned instead.
     */
    HYDErrorInvalidSourceObjectValue = 1,
    /*! The code that indicates the incoming source object's type is invalid.
     *  Not all mappers return this error code.
     */
    HYDErrorInvalidSourceObjectType = 2,
    /*! The code that indicates the resulting value it produced, or that a child mapper
     *  produced was an invalid type.
     */
    HYDErrorInvalidResultingObjectType = 3,
    
    /*! The code that indicates the current HYDError contains multiple errors.
     *  This is common for mappers that contain multiple mappers, or apply the same mapper
     *  across multiple objects.
     */
    HYDErrorMultipleErrors = 4,
    /*! The code that indicates there was an error when trying to access a given field on
     *  the source object. This can be due to invalid source object (eg - can't access the
     *  fields requested).
     */
    HYDErrorGetViaAccessorFailed = 5,
    /*! The code that indicates there was an error when trying to write to a given field on
     *  the source object. This can be due to invalid source object (eg - can't write to the
     *  fields requested), or because the values provided do not match the expected number
     *  of fields to update.
     */
    HYDErrorSetViaAccessorFailed = 6,
};

/*! The HYDError's userInfo key used to store the fact if this error is fatal.
 *  Fatal errors indicate failure to parse the given source object that meet all the
 *  requirements specified.
 *
 */
HYD_EXTERN NSString *HYDIsFatalKey;

/*! The HYDError's userInfo key used to store the array of underlying errors that this error hold.
 *  This is set when the error code is HYDErrorMultipleErrors.
 *
 *  HYDError will also set the classic, NSUnderlyingErrorKey key to the first error in this array.
 */
HYD_EXTERN NSString *HYDUnderlyingErrorsKey;

/*! The HYDError's userInfo key used to store the source object that was attempted to be mapped
 *  when the error occurred.
 *
 *  @warning If you're parsing potentially sensitive information, this could hold sensitive
 *           information if you're logging it or sending this over the wire.
 */
HYD_EXTERN NSString *HYDSourceObjectKey;

/*! The HYDError's userInfo key used to store the source key that the mapper extracted the
 *  sourceObject from. Depending on the mapper, this can be a KeyPath-like string to an element index
 *  of an array to a property or dictionary key access.
 */
HYD_EXTERN NSString *HYDSourceAccessorKey;

/*! The HYDError's userInfo key used to store the destination object that was attempted to be mapped
 *  when the error occurred. Most of the time, this will not be present, as mappers that fail to parse
 *  usually don't produce any values.
 *
 *  @warning If you're parsing potentially sensitive information, this could hold sensitive
 *           information if you're logging it or sending this over the wire.
 */
HYD_EXTERN NSString *HYDDestinationObjectKey;

/*! The HYDError's userInfo key used to store the destination key that the mapper would of set
 *  resulting object created from the source object. Depending on the mapper, this can be a
 *  KeyPath-like string to an element index of an array to a property or dictionary key access.
 */
HYD_EXTERN NSString *HYDDestinationAccessorKey;
