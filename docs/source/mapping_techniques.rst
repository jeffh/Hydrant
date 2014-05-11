.. highlight:: objective-c

.. _MappingTechniques:

==================
Mapping Techniques
==================

This is a list of various methods of parsing potentially problematic or
difficult input data. Prefer these techniques before having to resort to
using :ref:`HYDMapWithBlock` or :ref:`HYDMapWithPostProcessing`


Convert a value or return nil (or another default value)
========================================================

Use the :ref:`HYDMapOptionally` mapper::

    id<HYDMapper> mapper1 = HYDMapStringToURL();
    id<HYDMapper> mapper2 = HYDMapOptionallyTo(HYDMapStringToURL());

``mapper1`` one will produce a fatal error if given a value like ``@1`` but
``mapper2`` will return a non-fatal error with ``nil``.

Use it with :ref:`HYDMapObject`, to optionally map properties.


How do I return a source object's value unchanged?
==================================================

Just use :ref:`HYDMapIdentity`.


.. _OptionalArrayMapping:

Mapping an array of objects, excluding invalid ones instead of failing entirely
===============================================================================

Depending on the location of :ref:`HYDMapOptionally` in comparison to
:ref:`HYDMapArrayOf`, different behavior occurs::

    HYDMapOptionallyTo(HYDMapArrayOf(...))

This mapper will return ``nil`` if **any part of mapping the array fails**.
Where as::

    HYDMapArrayOf(HYDMapOptionallyTo(...))

Will **exclude any element that fails to parse** from the array. This is due
to the way ``HYDMapArrayOf`` excludes values from its mapper that produces
``nil`` and any kind of error (fatal or non-fatal).


.. _MappingMultipleValues:

Mapping Two Fields to One Property
==================================

This applies to any combination of mappings: many-to-one, one-to-many, or
many-to-many in a :ref:`MappingDataStructure`.

Explictly use :ref:`HYDKeyPathAccessor` with each key. The accessor will
produce an array of the values it has extracted::

    HYDMapObject([Employee class],
                 @{@[@"date", @"time"]: @[HYDMapByStringJoining(@"T"),
                                          HYDMapStringToDate(HYDDateFormatRFC3339),
                                          @"joinDate"]};
