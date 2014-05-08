.. highlight:: objective-c

================
Mapper Reference
================

Here lists all the mappers currently available in Hydrant. Composing these
mappers together provides the ability to (de)serialize for a wide variety of
use cases. All the functions listed here return objects that conform to the
:ref:`HYDMapper` protocol.

Constructor Helper Functions
============================

Nearly all mappers come with helper functions. These are simply overloaded c
functions that provide a way to construct mappers more succinctly. Since they
are overloaded they generally conform to the following style::

    HYDMapMapperName(...)
    HYDMapMapperName(id<HYDMapper> innerMapper, ...);

The former function is a convenience that converts to the latter function::

    HYDMapMapperName(HYDMapIdentity(), ...);

The :ref:`identity mapper <HYDIdentityMapper>` simply provides direct access to
the source object and provides a KVC-styled key accessor for parent mappers.

Inner mappers are receive the source object before the current mapper. This
allows chaining of complex conversion methods. For example::

    id<HYDMapper> mapper = HYDMapURLToStringFrom(HYDMapStringToURL())

This mapper composition produces strings that are valid URLs. Strings that
are not URLs fail to parse for this mapper. For readability, you can also
compose mappers in a chain using :ref:`HYDMapThread`.

For autocompleting convenience, all the helper functions are prefixed with
``HYDMap``. So :ref:`HYDEnumMapper` exposes constructor functions with
:ref:`HYDMapEnum`.

You might be thinking these overload functions require Objective-C++, but
:ref:`you'd be wrong <FunctionOverloading>`.


.. _TheReverseMapper:

The Reverse Mapper
==================

All mappers defined here fully support Hydrant's :ref:`HYDMapper` protocol
unless explicitly state otherwise. This means each mapper can create an
equivalent mapper that undoes the current mapper::

    id<HYDMapper> mapper = HYDMapStringToURL();
    id<HYDMapper> reversedMapper = [mapper reverseMapper];

    NSString *URI = @"http://jeffhui.net";
    // never pass nil to error, but here for brevity
    NSURL *url = [mapper objectFromSourceObject:URI error:nil];
    NSString *reversedURI = [reversedMapper objectFromSourceObject:url error:nil];

    assert [URI isEqual:reversedURI]; // equal

Mappers that are **lossy** cannot ensure the reversability will be exactly
equal, this currently only applies to :ref:`HYDMapForward` and
:ref:`HYDMapBackward`.


.. _HYDEnumMapper:
.. _HYDMapEnum:

HYDMapEnum
==========

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

    HYDMapEnum(NSDictionary *mapping);
    HYDMapEnum(id<HYDMapper> innerMapper, NSDictionary *mapping);

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

The internal implementation class is ``HYDEnumMapper``.


.. _HYDIdentityMapper:
.. _HYDMapIdentity:

HYDMapIdentity
==============

This mapper, as its name suggests, is a passthrough mapper. It simply returns
the source object as its destination object.

Sounds pretty useless, but it is used by other mappers as the "default" inner
mapper that can be used for chaining. Because of this, this mapper is used by
helper functions for nearly all the other mappers in Hydrant.


.. _HYDObjectToStringFormatterMapper:
.. _HYDMapObjectToStringByFormatter:

HYDMapObjectToStringByFormatter
===============================

This mapper utilizes `NSFormatter`_ to convert objects to strings. It uses the
``-[NSFormatter stringForObjectValue:]`` internally for this mapping while
conforming as a Hydrant mapper.

Formatters that return ``nil`` will make this mapper produce a fatal Hydrant
error.

For the reverse -- mapping a string to an object with an `NSFormatter`_, use
:ref:`HYDMapStringToObjectByFormatter`. Calling ``-[reverseMapper]`` will do
this with the same parameters provided to this mapper.

The helper functions are available for this mapper::

    HYDMapObjectToStringByFormatter(NSFormatter *formatter);
    HYDMapObjectToStringByFormatter(id<HYDMapper> innerMapper, NSFormatter *formatter);

This mapper is the underpinning for other mappers that utilize this internally:

- :ref:`HYDMapDateToString` - Converts a NSDate to NSString
- :ref:`HYDMapURLToString` - Converts an NSURL to NSString
- :ref:`HYDMapNumberToString` - Converts a number to NSString
- :ref:`HYDMapUUIDToString` - Converts an NSUUID to NSString

.. _HYDStringToObjectFormatterMapper:
.. _HYDMapStringToObjectByFormatter:

HYDMapStringToObjectByFormatter
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
:ref:`HYDMapObjectToStringByFormatter`.

The helper functions are available for this mapper::

    HYDMapStringToObjectByFormatter(NSFormatter *formatter);
    HYDMapStringToObjectByFormatter(id<HYDMapper> mapper, NSFormatter *formatter);

This mapper is the underpinning for other mappers that utilize this
internally:

- :ref:`HYDMapStringToDate` - Converts a NSString to NSDate
- :ref:`HYDMapStringToURL` - Convert a NSString to NSURL
- :ref:`HYDMapStringToNumber` - Converts a NSString to NSNumber
- :ref:`HYDMapStringToUUID` - Converts a NSString to NSUUID

.. _NSFormatter: https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/NSFormatter_Class/Reference/Reference.html


.. _HYDMapDateToString:

HYDMapDateToString
==================

This wraps around :ref:`HYDMapObjectToStringByFormatter` and provides
conviences for using an `NSDateFormatter`_ to map a date to a string.

The following helper functions are available::

    HYDMapDateToString(NSString *formatString);
    HYDMapDateToString(NSDateFormatter *dateFormatter)
    HYDMapDateToString(id<HYDMapper> innerMapper, NSString *formatString);
    HYDMapDateToString(id<HYDMapper> innerMapper, NSDateFormatter *dateFormatter)

Either you can provide date format string (or use one of Hydrant's
:ref:`DateFormatConstants`) or use a customized ``NSDateFormatter`` instance.

The reverse of this mapper is :ref:`HYDMapStringToDate`.


.. _HYDMapStringToDate:

HYDMapStringToDate
==================

This wraps around :ref:`HYDMapStringToObjectByFormatter` and provides
conviences for using an `NSDateFormatter`_ to map a string to a date.

The following helper functions are available::

    HYDMapStringToDate(NSString *formatString);
    HYDMapStringToDate(NSDateFormatter *dateFormatter)
    HYDMapStringToDate(id<HYDMapper> innerMapper, NSString *formatString);
    HYDMapStringToDate(id<HYDMapper> innerMapper, NSDateFormatter *dateFormatter)
    HYDMapStringToAnyDate();
    HYDMapStringToAnyDate(id<HYDMapper> innerMapper);

Either you can provide date format string (or use one of Hydrant's
:ref:`DateFormatConstants`) or use a customized ``NSDateFormatter`` instance.

``HYDMapStringToAnyDate`` attempts to parse the given string as any of the
dates specified in :ref:`DateFormatConstants`. Unsurprisingly, the mapper that
the function produces will have unreliable results when reversing.

The reverse of this mapper is :ref:`HYDMapDateToString`.

.. _NSDateFormatter: https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSDateFormatter_Class/Reference/Reference.html


.. _HYDMapStringToNumber:

HYDMapStringToNumber
====================

This provides conviences to :ref:`HYDMapStringToObjectByFormatter` by using
`NSNumberFormatter`_ to convert a string to an `NSNumber`_.

The following helper functions are available::

    HYDMapStringToDecimalNumber()
    HYDMapStringToNumber(id<HYDMapper> mapper)
    HYDMapStringToNumber(NSNumberFormatterStyle numberFormatStyle)
    HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatStyle)
    HYDMapStringToNumber(NSNumberFormatter *numberFormatter)
    HYDMapStringToNumber(id<HYDMapper> mapper, NSNumberFormatter *numberFormatter)

The reverse of this mapper is :ref:`HYDMapNumberToString`.

Converting an NSNumber to a c-native numeric type is not the
responsibility of this mapper, that is what :ref:`HYDMapKVCObject` does.


.. _HYDMapNumberToString:

HYDMapNumberToString
====================

This provides conviences to :ref:`HYDMapStringToObjectByFormatter` by using
`NSNumberFormatter`_ to convert an `NSNumber`_ to a string.

The following helper functions are available::

    HYDMapDecimalNumberToString()
    HYDMapNumberToString(id<HYDMapper> mapper)
    HYDMapNumberToString(NSNumberFormatterStyle numberFormatStyle)
    HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatterStyle numberFormatStyle)
    HYDMapNumberToString(NSNumberFormatter *numberFormatter)
    HYDMapNumberToString(id<HYDMapper> mapper, NSNumberFormatter *numberFormatter)

The reverse of this mapper is :ref:`HYDMapStringToNumber`.

Converting a c-native numeric type to an NSNumber is not the
responsibility of this mapper, that is what :ref:`HYDMapKVCObject` does.

.. _NSNumberFormatter: https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/NSNumberFormatter_Class/Reference/Reference.html
.. _NSNumber: https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/nsnumber_class/Reference/Reference.html

.. _HYDMapURLToString:

HYDMapURLToString
=================

This provides conviences to :ref:`HYDMapObjectToStringByFormatter` by using
:ref:`HYDURLFormatter` to convert an `NSURL` to a string.

The following helper functions are available::

    HYDMapURLToString();
    HYDMapURLToStringFrom(id<HYDMapper> innerMapper);
    HYDMapURLToStringOfScheme(NSArray *allowedSchemes)
    HYDMapURLToStringOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)

An array of schemes can be provided that the URL must conform to be valid. For
example, this mapper only accepts http urls::

    HYDMapURLToStringOfScheme(@["http", @"https"])

The reverse of this mapper is :ref:`HYDMapStringToDate`.


.. _HYDMapStringToURL:

HYDMapStringToURL
=================

This provides conviences to :ref:`HYDMapStringToObjectByFormatter` by using
:ref:`HYDURLFormatter` to convert a string to an `NSURL`_.

The following helper functions are available::

    HYDMapStringToURL();
    HYDMapStringToURLFrom(id<HYDMapper> innerMapper);
    HYDMapStringToURLOfScheme(NSArray *allowedSchemes)
    HYDMapStringToURLOfScheme(id<HYDMapper> mapper, NSArray *allowedSchemes)

An array of schemes can be provided that the URL must conform to be valid. For
example, this mapper only accepts http urls::

    HYDMapStringToURLOfScheme(@["http", @"https"])

The reverse of this mapper is :ref:`HYDMapDateToString`.

.. _NSURL: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/Reference/Reference.html


.. _HYDMapUUIDToString:

HYDMapUUIDToString
==================

This provides conviences to :ref:`HYDMapObjectToStringByFormatter` by using
:ref:`HYDUUIDFormatter` to convert an `NSUUID`_ to a string.

The following helper functions are available::

    HYDMapUUIDToString();
    HYDMapUUIDToStringFrom(id<HYDMapper> innerMapper);

The reverse of this mapper is :ref:`HYDMapStringToUUID`.


.. _HYDMapStringToUUID:

HYDMapStringToUUID
==================

This provides conviences to :ref:`HYDMapStringToObjectByFormatter` by using
:ref:`HYDUUIDFormatter` to convert a string to an `NSUUID`_.

The following helper functions are available::

    HYDMapStringToUUID();
    HYDMapStringToUUIDFrom(id<HYDMapper> innerMapper);

The reverse of this mapper is :ref:`HYDMapUUIDToString`.

.. _NSUUID: https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSUUID_Class/Reference/Reference.html


.. _HYDValueTransformerMapper:
.. _HYDMapValue:

HYDMapValue
===========

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

    HYDMapValue(NSValueTransformer *valueTransformer);
    HYDMapValue(id<HYDMapper> innerMapper, NSValueTransformer *valueTransformer);
    HYDMapValue(NSString *valueTransformerName);
    HYDMapValue(id<HYDMapper> innerMapper, NSString *valueTransformerName);

If your value transformer is registered as a singleton via
``+[NSValueTransformer setValueTransformer:forName:]``, then using the
constructor functions that accept a string as the second argument can be used
to easily fetch the value transformer by that name.


.. _HYDReversedValueTransformerMapper:
.. _HYDMapReverseValue:

HYDMapReverseValue
==================

This mapper utilizes `NSValueTransformer`_ to convert from one value to
another. It utilizes ``-[NSValueTransformer reverseTransformedValue:]``
internally to produce the resulting object.

This mapper assumes that all validation will be handled by the value
transformer. No additional validation is done. **It is impossible for this
mapper to return Hydrant errors**.

If constructing this mapper with a value transformer that cannot be reversed
will throw an exception. For the reverse of this mapper, see
:ref:`HYDMapValue` if you want to map values using
``-[NSValueTransformer transformValue:]``.

The helper functions are available for this mapper::

    HYDMapReverseValue(NSValueTransformer *valueTransformer);
    HYDMapReverseValue(id<HYDMapper> innerMapper, NSValueTransformer *valueTransformer);
    HYDMapReverseValue(NSString *valueTransformerName);
    HYDMapReverseValue(id<HYDMapper> innerMapper, NSString *valueTransformerName);

If your value transformer is registered as a singleton via
``+[NSValueTransformer setValueTransformer:forName:]``, then using the
constructor functions that accept a string as the second argument can be used
to easily fetch the value transformer by that name.

.. _NSValueTransformer: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSValueTransformer_Class/Reference/Reference.html


.. _HYDForwardMapper:
.. _HYDMapForward:

HYDMapForward
=============

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
:ref:`HYDMapBackward`.

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

HYDMapBackward
==============

This mapper is the reverse of :ref:`HYDForwardMapper` it generates a series of
repeated objects to that would allow the :ref:`HYDForwardMapper` to function on
the resulting object produced::

    id<HYDMapper> mapper = HYDMapBackward(@"person.account",
                                          HYDMapObject(HYDRootMapper, [Person class], [NSDictionary class],
                                                       @{@"firstName": @"first"}));

    Person *person = [[Person alloc] initWithFirstName:@"John"];

    HYDError *error = nil;
    id json = [mapper objectFromSourceObject:person error:&error];
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

HYDMapCollectionOf / HYDMapArrayOf
==================================

This mapper applies a child mapper to process a collection, usually an array of
items. Although this can apply to sets any other collection of items to map.
The child mapper is used to map each individual element of the collection::

    id<HYDMapper> childMapper = HYDMapObject([Person class],
                                             @{@"first": @"firstName"});
    id<HYDMapper> mapper = HYDMapCollectionOf(childMapper,
                                              [NSArray class], [NSArray class]);

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

The helper functions available for this mapper::

    HYDMapCollectionOf(id<HYDMapper> itemMapper, Class sourceCollectionClass, Class destinationCollectionClass)
    HYDMapCollectionOf(Class collectionClass)
    HYDMapCollectionOf(Class sourceCollectionClass, Class destinationCollectionClass)
    HYDMapCollectionOf(id<HYDMapper> itemMapper, Class collectionClass)
    HYDMapArrayOf(id<HYDMapper> itemMapper)
    HYDMapArrayOfObjects(Class sourceItemClass, Class destinationItemClass, NSDictionary *mapping)
    HYDMapArrayOfObjects(Class destinationItemClass, NSDictionary *mapping)

``HYDMapArrayOf`` are a set of convience functions that assume the source
and destination collection to be NSArrays. Further conviences are built
on top that to convert an array of objects into another array of objects.

``HYDMapArrayOfObjects`` is simply the composition::

    HYDMapArrayOf(HYDMapObject(...))

See :ref:`HYDMapObject` for more information on that mapper.

This mapper has some extra behavior based on the result of the child mapper.
Specifically, if a child mapper produces a ``nil`` value and a non-fatal error,
then its value is excluded from an array. This allows selective exclusion of
items from the source array in the resulting array.

For more details, see :ref:`OptionalArrayMapping`.


.. _HYDMapFirst:
.. _HYDMapFirstMapperInArray:
.. _HYDFirstMapper:

HYDMapFirst
===========

This mapper tries to apply each mapper its given until one succeeds (does not
return a fatal error). Using this mapper can provide an ordered list of mappers
to attempt. An example is an array that has different object types::

    id<HYDMapper> personMapper = HYDMapObject([Person class], {...});
    id<HYDMapper> employeeMapper = HYDMapObject([Person class], {...});
    id<HYDMapper> mapper = HYDMapArrayOf(HYDMapFirst(personMapper, employeeMapper));

``mapper`` will try using ``personMapper``, but if that mapper generates a fatal
error, then ``employeeMapper`` is used instead. If that fails, then it is
returned to the consumer of ``mapper``.

``HYDMapFirst`` is a macro around the constructor function::

    HYDMapFirstMapperInArray(NSArray *mappers)


.. _HYDMapNonFatally:
.. _HYDMapNonFatallyWithDefault:
.. _HYDMapNonFatallyWithDefaultFactory:
.. _HYDMapNonFatalMapper:

HYDMapNonFatally
================

The non-fatal mapper takes child mapper to process and converts any fatal
error that the child mapper produces into non-fatal ones::

    // This mapper will attempt to convert a string to an NSURL
    // or returns nil otherwise
    id<HYDMapper> mapper = HYDMapNonFatally(HYDMapStringToURL(...))

There are many helper functions which relate to producing default values::

    HYDMapNonFatally(id<HYDMapper> childMapper)
    HYDMapNonFatallyWithDefault(id<HYDMapper> childMapper, id defaultValue)
    HYDMapNonFatallyWithDefault(id<HYDMapper> childMapper, id defaultValue, id reverseDefault)
    HYDMapNonFatallyWithDefaultFactory(id<HYDMapper> childMapper, HYDValueBlock defaultValueFactory)
    HYDMapNonFatallyWithDefaultFactory(id<HYDMapper> childMapper, HYDValueBlock reversedDefaultFactory)

Which provides a variety of producing default values when fatal errors
are received. By default, ``nil`` is returned.

Also, you might want to use :ref:`HYDMapOptionally`, which composition this
with :ref:`HYDMapNotNull`.

.. _HYDMapNotNull:
.. _HYDMapNotNullFrom:
.. _HYDNotNullMapper:

HYDMapNotNull
=============

The mapper produces fatal errors if a ``nil`` or ``[NSNull null]`` is returned
by a given mapper::

    id<HYDMapper> mapper = HYDMapNotNull();
    id json = [NSNull null];
    HYDError *error = nil;
    // => produces fatal error
    [mapper objectFromSourceObject:json error:&error];

There are helper functions::

    HYDMapNotNull()
    HYDMapNotNullFrom(id<HYDMapper> innerMapper)

Also, you might want to use :ref:`HYDMapOptionally`, which composition this
with :ref:`HYDMapNonFatally`.

.. _HYDMapOptionally:
.. _HYDMapOptionallyTo:
.. _HYDMapOptionallyWithDefault:
.. _HYDMapOptionallyWithDefaultFactory:

HYDMapOptionally
================

This is the composition of :ref:`HYDMapNonFatally` and :ref:`HYDMapNotNull`
which produces a mapper that converts ``nil``, ``[NSNull null]`` or any
unmappable values into a default value provided.

The helper functions are based on the composition::

    HYDMapOptionally()
    HYDMapOptionallyTo(id<HYDMapper> innerMapper)
    HYDMapOptionallyWithDefault(id defaultValue)
    HYDMapOptionallyWithDefault(id<HYDMapper> innerMapper, id defaultValue)
    HYDMapOptionallyWithDefault(id<HYDMapper> innerMapper, id defaultValue, id reverseDefaultValue)
    HYDMapOptionallyWithDefaultFactory(HYDValueBlock defaultValueFactory)
    HYDMapOptionallyWithDefaultFactory(id<HYDMapper> innerMapper, HYDValueBlock defaultValueFactory)
    HYDMapOptionallyWithDefaultFactory(id<HYDMapper> innerMapper,
                                       HYDValueBlock defaultValueFactory,
                                       HYDValueBlock reverseDefaultValueFactory)

This is commonly used for conditionally allowing fields when
mapping with :ref:`HYDMapObject`::

    // first name is optional, last name is required
    HYDMapObject([Person class],
                 @{@"first": @[HYDMapOptionally(), @"firstName"],
                   @"last": @"lastName"});

    // this json causes a fatal error:
    id json = @{@"first": @"John"};

    // this json will produce a non-fatal error, and map to a Person object
    id json = @{@"last": @"Doe"};

    // this json will produce no error and map to a Person object
    id json = @{@"first": @"John",
                @"last": @"Doe"};


.. _HYDMapType:
.. _HYDMapTypes:
.. _HYDTypedMapper:

HYDMapTypes
===========

This mapper does type checking to ensure the given type is as intended.
Using this mapper can provide type checking to filter out nefarious input that
can potentially crash your application. If you're looking to apply this
upon an object's properties, use :ref:`HYDMapObject` instead -- which uses
this mapper internally. :ref:`HYDMapCollectionOf` also does some type checking
for the collection source class.

The mapper simply uses ``-[isKindOfClass:]`` to verify expected inputs and
outputs - returning a fatal error if this check fails.

Here are the following functions to construct this mapper::

    HYDMapType(Class sourceAndDestinationClass)
    HYDMapType(Class sourceClass, Class destinationClass)
    HYDMapTypes(NSArray *sourceClasses, NSArray *destinationClasses)
    HYDMapType(id<HYDMapper> innerMapper, Class sourceAndDestinationClass)
    HYDMapType(id<HYDMapper> innerMapper, Class sourceClass, Class destinationClass)
    HYDMapTypes(id<HYDMapper> innerMapper, NSArray *sourceClasses, NSArray *destinationClasses)

As the arguments suggest, you can provide multiple classes that are valid for
inputs or outputs. Passing ``nil`` as a class argument will allow
**any classes**. Source classes indicate values provided to the mapper, and
destination classes represent output (usually from the innerMapper).

For functions that accept an array, passing an empty array will also behave
like passing ``nil``.

.. _HYDMapTypeNote:
.. note:: This mapper can behave in unintuitive ways for inherited
          `class clusters`_. So specifying ``NSMutableDictionary`` and
          ``NSMutableArray`` will cause fatal type-checking errors. Use
          ``NSDictionary`` and ``NSArray`` instead.


.. _HYDMapKVCObject:
.. _HYDObjectMapper:

HYDMapKVCObject
===============

This uses Key-Value Coding to map arbitrary objects to one another, or the more
commonly known methods: ``-[setValue:forKey:]`` and ``-[valueForKey:]``. This
mapper provides a data-structure mapping DSL that conforms to a specific design
that is mentioned in the :ref:`MappingDataStructure`. But at an overview, they
usually look like one of two forms::

    @{@"get.KeyPath": @"set.KeyPath"}
    @{@"get.KeyPath": @[myMapper, @"set.KeyPath"]}

They both conform to KeyPath-like semantics, similar to the ``-[valueForKeyPath:]``
method, but without the aggregation features. They all read similarly to:

    Map 'get.KeyPath' to 'set.KeyPath' using myMapper

This is simply used as an abbreviated form to specify the mapping for each
property without the visual noise of objective-c styled object construction.
Again, read up on the :ref:`MappingDataStructure` to see the internal
representation this mapper uses after processing this data structure.

.. note:: Since this mapper uses ``setValue:forKey:`` and ``valueForKey:``, all
          the same consequences apply -- such as possibly setting invalid
          object types to properties. Use :ref:`HYDMapObject`, which adds
          type checking before mapping values to their destinations.

          And since this uses KVC, it will correctly convert boxed objects into
          their c-native types due to the implementation of KVC. This allows the
          rest of the mappers of Hydrant to use ``NSNumber`` which can get
          converted to integers, floats, doubles, etc.

If your key paths have dots, explicitly use :ref:`HYDKeyAccessor` and specify
the key::

    @{HYDKeyAccessor("json.key.with.dots"): @"key"}

Which can be useful for JSON that has dots in its key.

The following helper functions exist for this mapper::

    HYDMapKVCObject(id<HYDMapper> innerMapper, Class sourceClass, Class destinationClass, NSDictionary *mapping)
    HYDMapKVCObject(id<HYDMapper> innerMapper, Class destinationClass, NSDictionary *mapping)
    HYDMapKVCObject(Class sourceClass, Class destinationClass, NSDictionary *mapping)
    HYDMapKVCObject(Class destinationClass, NSDictionary *mapping)

The all functions, except for the first one, are derived off the first helper
function. If no mapper is provided, then :ref:`HYDMapIdentity` is used.
Similarly, if no sourceClass is provided, ``[NSDictionary class]`` is used.

The ``mapping`` argument conforms to the :ref:`MappingDataStructure`.

When specifying classes, this mapper will auto-promote them to their mutable
types. All destination classes are constructed using ``[destinationClass new]``.
Classes that support `NSMutableCopying`_ are created using
``[[destinationClass new] mutableCopy]``.

This makes it safe to use ``[NSDictionary class]`` and ``[NSArray class]`` as
arguments for the ``sourceClass`` and ``destinationClass``.

.. _NSMutableCopying: https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Protocols/NSMutableCopying_Protocol/Reference/Reference.html

This object fully supports reverseMapping, which allows you to quickly create
a serializer and deserializer combination.


.. _HYDMapObject:
.. _HYDTypedObjectMapper:

HYDMapObject
============

This maps arbitrary properties from one object to another using a KeyPath-like
mapping system. This mapper composes :ref:`HYDMapKVCObject` and
:ref:`HYDMapType` to produce a mapper that can check types as it is mapped to
its resulting object.

This mapper currently has tight-coupling around handling :ref:`HYDMapNonFatally`
to ensure that optional mappings can still work as intended.

The following helper functions exist similar to ``HYDMapKVCObject``::

    HYDMapObject(id<HYDMapper> innerMapper, Class sourceClass, Class destinationClass, NSDictionary *mapping)
    HYDMapObject(id<HYDMapper> innerMapper, Class destinationClass, NSDictionary *mapping)
    HYDMapObject(Class sourceClass, Class destinationClass, NSDictionary *mapping)
    HYDMapObject(Class destinationClass, NSDictionary *mapping)

And like ``HYDMapKVCObject``, the same default values apply:

    - ``innerMapper`` defaults to :ref:`HYDMapIdentity`
    - ``sourceClass`` defaults to ``[NSDictionary class]``

Not surprisingly this also accepts a ``mapping`` argument described
in the :ref:`MappingDataStructure`. One notable difference is that using
``HYDMapType`` are implicit for all arguments.

.. note:: This mapper also verifies the types of source and destination classes
          using :ref:`HYDMapType`, so the :ref:`same notice <HYDMapTypeNote>`
          applies here for all types that are verified.

If you're mapping a collection of objects (such as an array of objects), see
:ref:`HYDMapArrayOfObjects` which is a composition of this mapper and
``HYDMapArrayOf``.

If you prefer to not have type checking but still have the mapping
functionality, use the lower-level :ref:`HYDMapKVCObject` instead.

.. _class clusters: https://developer.apple.com/library/ios/documentation/general/conceptual/devpedia-cocoacore/ClassCluster.html


.. _HYDMapWithBlock:
.. _HYDBlockMapper:

HYDMapWithBlock
===============

.. note:: This is a convience to create custom Hydrant mappers. Blocks
          that execute custom code are subject to the same error handling that
          Hydrant expects for mappers to conform to :ref:`HYDMapper`
          in order to be exception-free.

This is a mapper that accepts one or two blocks for you to manually do the
conversion. Unlike most other mappers, this does not provide any safety, but
allows you do make trade-offs that go against Hydrant's design::

    - Make a certain subset of the object graph being mapped to be more
      performant (instead of defensively checking the data as Hydrant does).
    - Make a certain subset of the object graph "unsafe" and venerable to
      exceptions for easier debuggability.
    - Perform complex mappings that cannot be sanely abstracted
    - Quickly do one-off mappings for the perticular kind of data structure
      you're mapping (then ask: why are you using Hydrant then?)
    - Store mutable state during the mapping to do more complex mappings that
      Hydrant does not support.

**Try to avoid using this mapper**, because it provides no benefits from
implementing the serialization yourself. See :ref:`MappingTechniques` for
some tactics for mapping values without using this mapper.

These blocks take the same arguments as the ``HYDMapper`` protocol::

    typedef id(^HYDConversionBlock)(id incomingValue, __autoreleasing HYDError **error);

Where errors can be filled to indicate to parent mappers that mapping has
failed.

The helper functions for this mapper::

    HYDMapWithBlock(HYDConversionBlock convertBlock)
    HYDMapWithBlock(HYDConversionBlock convertBlock, HYDConversionBlock reverseConvertBlock)

Where the former function is an alias to latter as::

    HYDMapWithBlock(convertBlock, convertBlock)

The ``reverseConvertBlock`` is called when ``-[reverseMapper]`` is called on
the created mapper.


.. _HYDMapWithPostProcessing:
.. _HYDPostProcessingMapper:

HYDMapWithPostProcessing
========================

.. note:: This is a convience to create custom Hydrant mappers. Blocks
          that execute custom code are subject to the same error handling that
          Hydrant expects for mappers to conform to :ref:`HYDMapper`
          in order to be exception-free.

This is a mapper that allows you to perform "post processing" from another
mapper's work. Use this to "migrate" data structures that don't map cleanly
from the source objects to the destination objects.

Unlike :ref:`HYDMapWithBlock`, this mapper provides access to the source input
value and the resulting input value after executing the inner mapper.

Complex mappings across multiple source value fields can be done with this
mapper, at the same expenses the ``HYDMapWithBlock`` does::

    - Produce mappings that require composing multiple distinct parts of the
      source object.
    - Allows extra mutation after the creation of an resulting object.

**Try to avoid using this mapper**, because it provides no benefits from
implementing the serialization yourself. If you want to map multiple keys
to a single value, see :ref:`MappingMultipleValues`.

The helpers functions for this mapper::

    typedef void(^HYDPostProcessingBlock)(id sourceObject, id resultingObject, __autoreleasing HYDError **error);

    HYDMapWithPostProcessing(HYDPostProcessingBlock block)
    HYDMapWithPostProcessing(id<HYDMapper> innerMapper, HYDPostProcessingBlock block)
    HYDMapWithPostProcessing(id<HYDMapper> innerMapper, HYDPostProcessingBlock block, HYDPostProcessingBlock reverseBlock)

Where the first function is aliased to the last function as::

    HYDMapWithPostProcessing(HYDMapIdentity(), block, block)

and ``reverseBlock`` is the block that is invoked by the :ref:`TheReverseMapper`.

An easy example is to convert an array of keys and values into a dictionary and
then store it in a property of the resulting object::

    id<HYDMapper> personMapper = ...; // defined somewhere else

    // warning: there's no checking of sourceObject here, but you should
    // if it is coming from an unknown source or hasn't been composed
    // with HYDMapType
    id<HYDMapper> mapper = \
        HYDMapWithPostProcessing(personMapper, ^(id sourceObject, id resultingObject, __autoreleasing HYDError **error) {
            Person *person = resultingObject;
            person.phonesToFriends = [NSDictionary dictionaryWithObjects:sourceObject[@"names"] forKeys:sourceObject[@"numbers"]];
        });

    // example json
    id json = @{...
                @"names": [@"John", @"Jane"],
                @"numbers": @[@1234567, @7654321]};

    // post processor essentially does this:
    person.phonesToFriends = [NSDictionary dictionaryWithObjects:json[@"names"] forKeys:json[@"numbers"]]


.. _HYDMapReflectively:
.. _HYDReflectiveMapper:

HYDMapReflectively
==================

This builds upon various mappers and the Objective-C runtime to achieve the
dryest code possible, at the expense of internal complexity. It uses the runtime
to try and intelligently fill mappings:

    - Convert strings to dates with :ref:`HYDMapStringToDate`
    - Coerces some core types among each other: ``NSString``, ``NSNumber``,
      c numerics.
    - Type check incoming values with :ref:`HYDMapType` to match the types
      of the properties being assigned
    - Type check the incoming source object before doing any parsing.

Since this mapper cannot determine the intended reverse mapping, you must
explicitly state them.

.. info:: Currently, this mapper does not support non-numeric c types (structs,
          C++ classes, etc.).

.. warning:: WIP: Please do not use yet.

.. _HYDMapDispatch:
.. _HYDDispatchMapper:

HYDMapDispatch
==============

.. warning:: WIP: Please do not use yet.


.. _HYDMapThread:
.. _HYDThreadMapper:

HYDThreadMapper
===============

.. warning:: WIP: Please do not use yet.
