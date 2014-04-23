.. highlight:: objective-c

===========================
Value Transformer Reference
===========================

This is the reference documentation for all the `NSValueTransformers`_ that
Hydrant implements as conviences for you. Currently, these transformers are
intended to be used with :ref:`HYDMapReflectively`.

They are also publicly exposed if you need or prefer to use these classes
for other purposes.

.. _NSValueTransformers:  https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/NSFormatter_Class/Reference/Reference.html


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
