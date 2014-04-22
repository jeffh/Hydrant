.. highlight:: objective-c

=================
Advanced Mappings
=================

This is a list of various advanced methods of parsing potentially problematic
or difficult input data.

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
