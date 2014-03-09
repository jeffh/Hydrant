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

    HYDMapMapperName(HYDIdentityMapper(destinationKey), ...);

The identity mapper simply provides direct access to the source object and
provides a KVC-styled key accessor for parent mappers.

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

HYDObjectToStringFormatterMapper
=================================

This mapper utilizes NSFormatter to convert objects to strings. It uses the
``-[NSFormatter stringForObjectValue:]`` internally for this mapping while
conforming as a mapper.

For the revese -- mapping a string to an object with an ``NSFormatter``, use
``HYDStringToObjectMapper``.

The helper functions are available for this mapper::

    HYDMapObjectToStringByFormatter(NSString *destinationKey, NSFormatter *formatter);
    HYDMapObjectToStringByFormatter(id<HYDMapper> mapper, NSFormatter *formatter);

This mapper is the underpinning for other mappers that utilize this internally:

- HYDDateToStringMapper
- HYDURLToStringMapper
- HYDNumberToStringMapper
- HYDUUIDToStringMapper


