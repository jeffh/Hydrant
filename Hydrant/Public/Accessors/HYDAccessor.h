#import "HYDBase.h"

@class HYDError;

/*! The protocol used to by mappers to read and write to properties on a given source/destination object.
 *
 *  This provides an abstraction for mappers to not have to be concerned
 *  with how to extract values from objects. Accessors can also extract
 *  and set multiple values at once so mappers can multiplex values
 *  from many-to-many or one-to-one to any combination in between. That
 *  being said, most mappers are currently unaware of this feature.
 *
 *  @warning This protocol is relatively new and hasn't full stabilized yet.
 *           It may change more often that HYDMapper protocol.
 *
 *  A simple implementation is HYDKeyAccessor, which uses
 *  Key-Value Coding to extract and set values.
 *
 *  Mappers that are utilizing this abstract should bubble errors
 *  that accessors produce similarly to child mappers.
 *
 *  @see HYDKeyAccessor
 *  @see HYDKeyPathAccessor
 */
@protocol HYDAccessor <NSObject, NSCopying>

/*! Get values from the given source object.
 *
 *  Mappers use this method to extract values from a given source object.
 *
 *  @param sourceObject the source object to extract values from
 *  @param error If the source object does not have the desired values
 *               that the accessor extracted, then this error parameter
 *               is filled out.
 *
 *  @returns An array of values extracted from the source object.
 */
- (NSArray *)valuesFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error;

/*! Sets values on to the destination object.
 *
 *  Mappers use this method to set values on a given destination object.
 *
 *  @param values the array of values to set on the destination object.
 *  @param destinationObject the object to set the values onto.
 *
 *  @returns An error, if one occurred, indicating failure to set the values onto the destination object.
 */
- (HYDError *)setValues:(NSArray *)values onObject:(id)destinationObject;

/*! Returns human-readable names of the values being extracted/set.
 *
 *  This is simply for debuggability purposes. HYDError emits field names to make it easier to debug
 *  errors in mapping operations.
 *
 *  While there is no standard format, each element should be in KVC-style form.
 */
- (NSArray *)fieldNames;

@end
