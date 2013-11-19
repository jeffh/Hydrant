#import <Foundation/Foundation.h>

@protocol JKSSerializer;

/*! The Protocol to hook into the serialization/deserialization process.
 *
 * JKSMappers perform the primary work to convert various object types into their corresponding
 * value for another object.
 */
@protocol JKSMapper <NSObject>

/*! The destination key that the parsed object should be stored on for the destination object.
 *  Most mappers use a @property and recieve the argument in their constructors.s
 *
 * @returns A key path-compatible string representing the property to assign to.
 */
- (NSString *)destinationKey;

/*! The transformation of the sourceObject to be assigned to the `destinationKey`.
 *
 *  If you wish to dynamically or recursively construct an object.
 *  Use the methods available on the serializer.
 *
 * @param sourceObject The received object to convert. This should generally assume a JSON-compatible object on default construction.
 * @param serializer The serializer that is in the process of deserializing. Provides helper methods related to serialization.
 * @returns A newly created object to be assigned to an object by teh `destinationKey` method.
 */
- (id)objectFromSourceObject:(id)sourceObject serializer:(id<JKSSerializer>)serializer;

/*! The reverse mapper object that does the inverse conversion of this mapper.
 *
 * @param destinationKey The new destination key path-compatible string representing the property name to assign to.
 * @returns A JKSMapper conforming object that can perform the inverse conversion of the current mapper.
 */
- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey;

@end
