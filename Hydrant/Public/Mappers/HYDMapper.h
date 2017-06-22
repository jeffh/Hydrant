#import <Foundation/Foundation.h>

@protocol HYDAccessor;
@class HYDError;

/*! The Protocol for Hydrant's object mapping system.
 *
 *  HYDMapper defines a protocol to translate between one object and
 *  another.
 *
 *  HYDMapper are also designed to be composable, so a HYDMapper can
 *  map between two objects using a collection of HYDMappers.
 *
 *  @see HYDObjectToStringFormatterMapper for a simple mapper implementation.
 *  @see HYDObjectMapper for a complex mapper implementation.
 */
@protocol HYDMapper <NSObject>

#pragma mark - Translation Strategies

/*! The transformation of the sourceObject to be assigned to the `destinationAccessor`.
 *
 *  It is acceptable to return an object AND error. This indicates
 *  there was a partial error parsing the sourceObject, but
 *  recoverable enough to parse an object. The error should contain
 *  details of abnormal parsing behavior (eg - HYDNonFatalMapper).
 *
 *  To truly know if the provided source object is valid, consulting
 *  the error object's -[HYDError isFatal] boolean is necessary
 *
 *  @param sourceObject The received object to convert. This should
 *                      generally refer to the JSON or object being
 *                      serialized.
 *  @param error If the source object could not be converted without
 *               any errors it is filled in here. Note the object
 *               returned may still not be nil. It is the responsibility
 *               of the mapper to set this to nil if there are no errors,
 *               or not deref the pointer if error is nil to start with.
 *  @returns A newly created object to be assigned to an object by
 *           the `destinationAccessor` method.
 */
- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error;

#pragma mark - Mapper Composition

/*! The reverse mapper object that does the inverse conversion of this mapper.
 *
 *  This provides a handy way to reverse a mapping operation. Parent mappers can
 *  call this method on all its children to build a reversed-parent mapper.
 *
 *  @returns A HYDMapper conforming object that can perform the inverse conversion of
 *           the current mapper.
 */
- (id<HYDMapper>)reverseMapper;

@end
