.. highlight:: objective-c

===================
Formatter Reference
===================

This is the reference documentation for all the `NSFormatters`_ that
Hydrant implements as conveniences for you. When using mappers that utilize
formatters:

    - :ref:`HYDMapObjectToStringByFormatter`
        - :ref:`HYDMapDateToString`
        - :ref:`HYDMapNumberToString`
        - :ref:`HYDMapUUIDToString`
        - :ref:`HYDMapURLToString`
    - :ref:`HYDMapStringToObjectByFormatter`
        - :ref:`HYDMapStringToDate`
        - :ref:`HYDMapStringToNumber`
        - :ref:`HYDMapStringToUUID`
        - :ref:`HYDMapStringToURL`

They are also publicly exposed if you need or prefer to use these classes
for other purposes.

.. _NSFormatters: https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/NSFormatter_Class/Reference/Reference.html


.. _DateFormatConstants:

Date Format Strings
===================

Hydrant also includes a variety of constants that map to common datetime
formats that you can use for `NSDateFormatter`_::

    NSString *HYDDateFormatRFC3339 = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ";
    NSString *HYDDateFormatRFC3339_milliseconds = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ";

    NSString *HYDDateFormatRFC822_day_seconds_gmt = @"EEE, d MMM yyyy HH:mm:ss zzz";
    NSString *HYDDateFormatRFC822_day_gmt = @"EEE, d MMM yyyy HH:mm zzz";
    NSString *HYDDateFormatRFC822_day_seconds = @"EEE, d MMM yyyy HH:mm:ss";
    NSString *HYDDateFormatRFC822_day = @"EEE, d MMM yyyy HH:mm";
    NSString *HYDDateFormatRFC822_seconds_gmt = @"d MMM yyyy HH:mm:ss zzz";
    NSString *HYDDateFormatRFC822_gmt = @"d MMM yyyy HH:mm zzz";
    NSString *HYDDateFormatRFC822_seconds = @"d MMM yyyy HH:mm:ss";
    NSString *HYDDateFormatRFC822 = @"d MMM yyyy HH:mm";


.. _HYDDotNetDateFormatter:

HYDDotNetDateFormatter
======================

This is an `NSDateFormatter`_ subclass that supports parsing of microsoft AJAX
date formats which look like ``@"/Date(123456)/"``.

Since formatter sets some internal state from ``NSDateFormatter``, so changing
this formatter via properties may break its intended behavior.

.. _NSDateFormatter: https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSDateFormatter_Class/Reference/Reference.html


.. _HYDURLFormatter:

HYDURLFormatter
===============

This formatter utilizes `NSURL`_ to generate URLs and adds some extra safety
by checking inputs before trying to construct an ``NSURL``.

It can optionally be constructed with a set of schemes to allow.

.. _NSURL: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/Reference/Reference.html


.. _HYDUUIDFormatter:

HYDUUIDFormatter
================

This formatter utilizes `NSUUID`_ to generate UUIDs and adds some extra safety
by checking inputs before trying to construct an ``NSUUID``.

.. _NSUUID: https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSUUID_Class/Reference/Reference.html
