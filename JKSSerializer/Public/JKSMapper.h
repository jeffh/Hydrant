#import <Foundation/Foundation.h>

@protocol JKSFactory;

/*! The Protocol for object mapping.
 *
 *  JKSMapper defines a protocol to translate between one object and
 *  another.
 *
 *  JKSMapper are also designed to be composable, so a JKSMapper can
 *  map between two objects using a collection of JKSMappers.
 */
@protocol JKSMapper <NSObject>

#pragma mark - Translation Strategies

/*! The transformation of the sourceObject to be assigned to the `destinationKey`.
 *
 *  If you wish to dynamically or recursively construct an object.
 *  Use the methods available on the serializer.
 *
 *  @param sourceObject The received object to convert. This should generally assume a JSON-compatible object on default construction.
 *  @param error If the source object could not be converted, an error is filled here.
 *  @returns A newly created object to be assigned to an object by teh `destinationKey` method.
 */
- (id)objectFromSourceObject:(id)sourceObject error:(NSError *__autoreleasing *)error;

/*! Creates a newly created object from a sourceObject using the specified class mapping.
 *
 *  Unlike `-[objectFromSourceObject:]` the specifically defined serialization strategy is used.
 *
 *  @param sourceObject the source object to serialize.
 *  @param dstClass The class of the object to produce after serialization.
 *  @param error If the source object could not be converted, an error is filled here.
 *  @returns An instance of `dstClass` with the serializing values of `sourceObject` transferred to it.
 */
- (id)objectFromSourceObject:(id)sourceObject toClass:(Class)dstClass error:(NSError *__autoreleasing *)error;

#pragma mark - Mapper Composition

/*! Mappers are given two objects that may assist in processing when
 *  translating between two objects before translating object(s).
 *
 *  This method is invoked only if the current mapper is contained
 *  in another mapper's translation strategy.
 *
 *  For container mappers, it is also responsible for calling this to all mappers it contains.
 *
 *  @param mapper The mapper object that initiated the object mapping. This is useful for translating an arbitrary object.
 *                This should be weakly retained to avoid any memory leaks.
 *  @param factory The factory that can produce objects of a particular class easily (eg - NSMutableArrays).
 */
- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory;

/*! The destination key that the parsed object should be stored on for the destination object.
 *  Most mappers use a @property and receive the argument in their constructors.
 *
 *  This is primarily used by a "parent" JKSMapper object to know where to place this object.
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
 *  @returns A JKSFieldMapper conforming object that can perform the inverse conversion of the current mapper.
 */
- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey;

@end