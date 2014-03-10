.. highlight:: objective-c

================
Mapper Reference
================

Here lists all the mappers currently available in Hydrant. Composing these
mappers together provides the ability to do data mapping and serialization.

Constructor Helper Functions
============================

Nearly all mappers come with helper functions. These are simply overloaded c
functions that provide a way to construct mappers more succinctly. Since they
are overloaded they generally conform to the following style::

    HYDMapMapperName(NSString *destinationKey, ...);
    HYDMapMapperName(id<HYDMapper> mapper, ...);

The first function is a convenience to do the following::

    HYDMapMapperName(HYDMapIdentity(destinationKey), ...);

The :ref:`identity mapper <HYDIdentityMapper>` simply provides direct access to
the source object and provides a KVC-styled key accessor for parent mappers.

If the mapper is the mapping the source object directly (eg - the top-most
mapper), then you can use ``HYDRootMapper`` constant as the first argument to
indicate that::

    // HYDMapObject is top-most mapper, use HYDRootMapper
    id<HYDMapper> mapper = HYDMapObject(
        HYDRootMapper, [Person class],
        // this mapper is part of the object mapper, which would want to know
        // where this url is mapped to on the Person class, so we have to
        // specify it here.
        @{@"homepage": HYDMapStringToURL(@"homepage")}
    );

For autocompleting convenience, all the helper functions are prefixed with
``HYDMap``.

.. _HYDEnumMapper:
.. _HYDMapEnum:

HYDEnumMapper
=============

The enum mapper uses a dictionary to map values from the source object to the
destination object. This is typically used for mapping strings to an enum
equivalent.

.. warning:: The mapping dictionary for this mapper is assumed to have a
             one-to-one mapping for its keys and values. Any key that maps to
             the same value or vice versa will cause undefined behavior. Future
             versions of Hydrant may choose to make this error throw an
             exception.

Any values that do not match the enum will make this mapper produce a fatal
error. To provide an optional default, wrap with ``HYDOptionalMapper``.

The following helper functions are available for this mapper::

    HYDMapEnum(NSString *destinationKey, NSDictionary *mapping);
    HYDMapEnum(id<HYDMapper> mapper, NSDictionary *mapping);

With the ``mapping`` dictionary mapping source object values to destination
object values. Remember that all values in the mapping need to be an object::

    // defined somewhere...
    typedef NS_ENUM(NSUInteger, PersonGender) {
        PersonGenderUnknown,
        PersonGenderMale,
        PersonGenderFemale,
    };

    // building the mapper
    HYDMapEnum(HYDRootMapper,
               @{@"male": @(PersonGenderMale),
                 @"female": @(PersonGenderFemale),
                 @"unknown": @(PersonGenderUnknown)});

.. _HYDIdentityMapper:
.. _HYDMapIdentity:
.. _HYDMapKey:
.. _HYDMapKeyPath:

HYDIdentityMapper
=================

This mapper, as its name suggests, is a pass through mapper. It simply returns
the source object as its destination object.

Sounds pretty useless, but it conforms to the ``HYDMapper`` protocol, and
provides the bridging between the ``HYDAccessor`` interface for
``-[destinationAccessor]`` of the mapper protocol. Because of this, this mapper
is used by helper functions for nearly all the other mappers in Hydrant.

The helper functions are available for this mapper::

    HYDMapIdentity(id<HYDAccessor> destinationAccessor);
    HYDMapIdentity(NSString *destinationKey);
    HYDMapKey(NSString *destinationKey);
    HYDMapKeyPath(NSString *destinationKey);

The first function is the fundamental function with all the others are built on
top of. HYDMapIdentity uses the default accessor that Hydrant uses internally,
which is currently ``HYDMapKeyPath``. Helper functions for other mappers use
``HYDMapIdentity`` internally when they accept a ``NSString *destinationKey``
argument.

``HYDMapKey`` performs only direct key access which can be useful for reading
dictionary keys that have periods in them. Otherwise, ``HYDMapKeyPath``
provides KVC key path like traversing behavior which useful in more cases.

.. _HYDObjectToStringFormatterMapper:
.. _HYDMapObjectToStringByFormatter:

HYDObjectToStringFormatterMapper
================================

This mapper utilizes `NSFormatter`_ to convert objects to strings. It uses the
``-[NSFormatter stringForObjectValue:]`` internally for this mapping while
conforming as a Hydrant mapper.

Formatters that return ``nil`` will make this mapper produce a fatal Hydrant
error.

For the reverse -- mapping a string to an object with an `NSFormatter`_, use
:ref:`HYDStringToObjectMapper`.

The helper functions are available for this mapper::

    HYDMapObjectToStringByFormatter(NSString *destinationKey, NSFormatter *formatter);
    HYDMapObjectToStringByFormatter(id<HYDMapper> mapper, NSFormatter *formatter);

This mapper is the underpinning for other mappers that utilize this internally:

- :ref:`HYDDateToStringMapper`, :ref:`HYDMapDateToString`
- :ref:`HYDURLToStringMapper`, :ref:`HYDMapURLToString`
- :ref:`HYDNumberToStringMapper`, :ref:`HYDMapNumberToString`
- :ref:`HYDUUIDToStringMapper`, :ref:`HYDMapUUIDToString`

.. _HYDStringToObjectFormatterMapper:
.. _HYDMapStringToObjectByFormatter:

HYDStringToObjectFormatterMapper
================================

This mapper utilizes `NSFormatter`_ to convert strings to objects. It uses
``-[NSFormatter getObjectValue:forString:errorDescription:]`` internally for
this mapping while conforming as a Hydrant mapper.

In addition, this mapper will validate that the source object is a valid string
before passing it through to the formatter. When an error description is
returned, Hydrant will insert it into an NSError instance like::

    [NSError errorWithDomain:NSCocoaErrorDomain
        code:NSFormattingError
        userInfo:@{NSLocalizedDescriptionKey: errorDescription}];

If errorDescription is not provided but success is still ``NO``, then a generic
errorDescription is created as a placeholder.

Following the creating of the NSError, it is wrapped inside a Hydrant error for
compatibility with the reset of Hydrant as a fatal error.

For the reverse -- mapping an object to a string with an `NSFormatter`_, use
:ref:`HYDObjectToStringFormatterMapper`.

The helper functions are available for this mapper::

    HYDMapStringToObjectByFormatter(NSString *destinationKey, NSFormatter *formatter);
    HYDMapStringToObjectByFormatter(id<HYDMapper> mapper, NSFormatter *formatter);

This mapper is the underpinning for other mappers that utilize this
internally:

- :ref:`HYDStringToDateMapper`, :ref:`HYDMapStringToDate`
- :ref:`HYDStringToURLMapper`, :ref:`HYDMapStringToURL`
- :ref:`HYDStringToNumberMapper`, :ref:`HYDMapStringToNumber`
- :ref:`HYDStringToUUIDMapper`, :ref:`HYDMapStringToUUID`

.. _NSFormatter: https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/NSFormatter_Class/Reference/Reference.html

.. _HYDValueTransformerMapper:
.. _HYDMapValue:

HYDValueTransformerMapper
=========================

This mapper utilizes `NSValueTransformer`_ to convert from one value to
another. It utilizes ``-[NSValueTransformer transformValue:]`` internally for
this mapping while conforming to the Hydrant mapper protocol.

HYDValueTransformerMapper assumes that all validation will be handled by the
value transformer. No addition validation is done. **It is impossible
for this mapper to return Hydrant errors**.

If the value transformer is reversable, then this mapper can be reversed. It
produces :ref:`HYDReversedValueTransformerMapper` which you can also use
directly if you want to apply the reversed transformation to a source object.

Attempting to produce a reverse mapper when the transformer cannot be reversed
will throw an exception.

The helper functions are available for this mapper::

    HYDMapValue(NSString *destinationKey, NSValueTransformer *valueTransformer);
    HYDMapValue(id<HYDMapper> mapper, NSValueTransformer *valueTransformer);
    HYDMapValue(NSString *destinationKey, NSString *valueTransformerName);
    HYDMapValue(id<HYDMapper> mapper, NSString *valueTransformerName);

If your value transformer is registered as a singleton via
``+[NSValueTransformer setValueTransformer:forName:]``, then using the
constructor functions that accept a string as the second argument can be used
to easily fetch the value transformer by that name.

.. _HYDReversedValueTransformerMapper:
.. _HYDMapReverseValue:

HYDReversedValueTransformerMapper
=================================

This mapper utilizes `NSValueTransformer`_ to convert from one value to
another. It utilizes ``-[NSValueTransformer reverseTransformedValue:]``
internally to produce the resulting object.

HYDReversedValueTransformerMapper assumes that all validation will be handled
by the value transformer. No additional validation is done. **It is impossible
for this mapper to return Hydrant errors**.

If constructing this mapper with a value transformer that cannot be reversed
will throw an exception. For the reverse of this mapper, see
:ref:`HYDValueTransformerMapper` if you want to map values using
``-[NSValueTransformer transformValue:]``.

The helper functions are available for this mapper::

    HYDMapReverseValue(NSString *destinationKey, NSValueTransformer *valueTransformer);
    HYDMapReverseValue(id<HYDMapper> mapper, NSValueTransformer *valueTransformer);
    HYDMapReverseValue(NSString *destinationKey, NSString *valueTransformerName);
    HYDMapReverseValue(id<HYDMapper> mapper, NSString *valueTransformerName);

If your value transformer is registered as a singleton via
``+[NSValueTransformer setValueTransformer:forName:]``, then using the
constructor functions that accept a string as the second argument can be used
to easily fetch the value transformer by that name.

.. _NSValueTransformer: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSValueTransformer_Class/Reference/Reference.html

.. _HYDForwardMapper:
.. _HYDMapFoward:

HYDForwardMapper
================

This mapper traverses the source object before sending the traversed sub-source
object to the child mapper its given. This allows for selectively ignoring
various parts of a data structure from the incoming source object::

    id<HYDMapper> mapper = HYDMapForward(@"person.account",
                                         HYDMapObject(HYDRootMapper, [Person class],
                                                      @{@"first": @"firstName"}));

    id json = @{@"person": @{@"account": @{@"first": @"John"}}};

    HYDError *error = nil;
    Person *person = [mapper objectFromSourceObject:json error:&error];
    // person.firstName => @"John"

Since this is lossy, reversing this mapper cannot produce any extra data that
was truncated by the traversal. The reversed mapper of this produces a
:ref:`HYDBackwardMapper`.

The helper functions available for this mapper::

    HYDMapForward(NSString *walkKey, Class sourceClass, id<HYDMapper> childMapper); 
    HYDMapForward(id<HYDAccessor> walkAccessor, Class sourceClass, id<HYDMapper> childMapper); 
    HYDMapForward(NSString *walkKey, id<HYDMapper> childMapper); 
    HYDMapForward(id<HYDAccessor> walkAccessor, id<HYDMapper> childMapper); 

The first argument for all these constructors are how to walk through through
the incoming mapping. The last argument is the child mapper to process the
subset of the source object being traversed by the first argument.

When not provided, ``sourceClass`` defaults to ``[NSDictionary class]``, this is
to hint to the reversed mapper how to produce the parent object.

.. _HYDBackwardMapper:
.. _HYDMapBackward:

HYDBackwardMapper
=================

This mapper is the reverse of :ref:`HYDForwardMapper` it generates a series of
repeated objects to that would allow the :ref:`HYDForwardMapper` to function on
the resulting object produced::

    id<HYDMapper> mapper = HYDMapBackward(@"person.account",
                                          HYDMapObject(HYDRootMapper, [Person class], [NSDictionary class],
                                                       @{@"firstName": @"first"}));

    Person *person = [[Person alloc] initWithFirstName:@"John"];

    HYDError *error = nil;
    id json = [mapper objectFromSourceObject:json error:&error];
    // json => @{@"person": @{@"account": @{@"first": @"John"}}};

Since this mapper simply recursively creates the class it was given to produce
the hierarchy.

The helper functions available for this mapper::

    HYDMapBackward(NSString *walkKey, Class destinationClass, id<HYDMapper> childMapper); 
    HYDMapBackward(id<HYDAccessor> walkAccessor, Class destinationClass, id<HYDMapper> childMapper); 
    HYDMapBackward(NSString *walkKey, id<HYDMapper> childMapper); 
    HYDMapBackward(id<HYDAccessor> walkAccessor, id<HYDMapper> childMapper); 

The first argument for all these constructors are the path of the keys to
create recursively. The last argument is the child mapper to produce the final
object that will be placed in the leaf of the path presented by the first
argument.

When not provided, ``destinationClass`` defaults to ``[NSDictionary class]``, this is
to hint to the reversed mapper how to produce the parent objects. The
destinationClass is instanciated with ``[[NSObject alloc] init]``. If the
class supports ``NSMutableCopying``, then a mutableCopy is created to work with
immutable data types (eg - NSDictionary which needs to be converted to
NSMutableDictionary).

.. _HYDCollectionMapper:
.. _HYDMapCollectionOf:
.. _HYDMapArrayOf:
.. _HYDMapArrayOfObjects:
.. _HYDMapArrayOfKVCObjects:

HYDCollectionMapper
===================

This mapper applies a child mapper to process a collection, usually an array of
items. Although this can apply to sets any other collection of items to map.
The child mapper is used to map each individual element of the collection::

    id<HYDMapper> childMapper = HYDMapObject(HYDRootMapper, [Person class],
                                             @{@"first": @"firstName"});
    id<HYDMapper> mapper = HYDMapCollectionOf(childMapper, [NSArray class], [NSArray class]);

    HYDError *error = nil;
    id json = @[
        @{@"first": @"John"},
        @{@"first": @"Jane"},
        @{@"first": @"Joe"},
    ];
    NSArray *people = [mapper objectFromSourceObject:json error:error];
    // people => @[<Person: John>, <Person: Jane>, <Person: Joe>]

HYDCollectionMapper will validate the incoming source object's enumerability
by checking if it is the given source class.

