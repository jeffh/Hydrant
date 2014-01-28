#import <Foundation/Foundation.h>

@protocol HYDFactory;
@class HYDError;

/*! The Protocol for Hydrant's object mapping system.
 *
 *  HYDMapper defines a protocol to translate between one object and
 *  another.
 *
 *  HYDMapper are also designed to be composable, so a HYDMapper can
 *  map between two objects using a collection of JOMMappers.
 *
 *  @see HYDObjectToStringFormatterMapper for a simple mapper implementation.
 *  @see HYDKeyValueMapper for a complex mapper implementation.
 */
@protocol HYDMapper<NSObject>

#pragma mark - Translation Strategies

/*! The transformation of the sourceObject to be assigned to the `destinationKey`.
 *
 *  It is acceptable to return an object AND error. This indicates
 *  there was a partial error parsing the sourceObject, but
 *  recoverable enough to parse an object. The error should contain
 *  details of abnormal parsing behavior (eg - HYDOptionalMapper).
 *
 *  To truly know if the provided source object is valid, consulting
 *  the error object's -[HYDError isFatal] boolean is necessary
 *
 *  @param sourceObject The received object to convert. This should
 *                      generally assume a JSON-compatible object
 *                      on default construction.
 *  @param error If the source object could not be converted without
 *               any errors it is filled in here. Note the object
 *               returned may still not be nil.
 *  @returns A newly created object to be assigned to an object by
 *           the `destinationKey` method. A nil-returned value
 *           either indicates an error.
 */
- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error;

#pragma mark - Mapper Composition

/*! The destination key that the parsed object should be stored on for the destination object.
 *  Most mappers use a @property and receive the argument in their constructors.
 *
 *  This is primarily used by a "parent" HYDMapper object to know where to place this object.
 *
 *  @returns A key path-compatible string representing the property to assign to.
 */
- (NSString *)destinationKey;

/*! The reverse mapper object that does the inverse conversion of this mapper.
 *
 *  This provides a handy way to reverse a mapping operation, which
 *  parents can then utilize to provide more complex reverse mapping
 *  features.
 *
 *  @param destinationKey The new destination key path-compatible string representing the property name to assign to.
 *  @returns A JOMFieldMapper conforming object that can perform the inverse conversion of the current mapper.
 */
- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey;

@end
