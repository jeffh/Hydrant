.. highlight:: objective-c

==================
Accessor Reference
==================

Here lists all the accessors currently available in Hydrant. Accessors
abstract the details of getting and setting values from objects so that each
:ref:`HYDMapper` does not have to implement them individually. All the functions
listed here return objects that conform to the :ref:`HYDAccessor` protocol.

You might be thinking the overload functions listed require Objective-C++, but
:ref:`you'd be wrong <FunctionOverloading>`.


.. _HYDAccessKeyPath:
.. _HYDAccessKeyPathInArray:
.. _HYDKeyPathAccessor:

HYDAccessKeyPath
================

This accessor provides KeyPath-styled access to objects. They only support the
dot-access from KeyPath to walk nested data structures. Like :ref:`HYDAccessKey`,
this mapper will correctly convert boxed typed into their native c-types since
it internally uses ``-[valueForKey:]`` and ``-[setValue:forKey:]``.

If given ``[NSNull null]`` values, when setting values, then that **assignment
is considered a no-op**, not assigning to nil. This is because the accessor
cannot safely assign ``nil`` vs ``[NSNull null]`` (eg - property vs dictionary
key).

There is a macro to create this accessor:

    HYDAccessKeyPath(...)

Which takes a variatic sequence of NSStrings that represent the keyPaths to
walk. Giving multiple keyPaths will generate a large array value and the
expected input values when setting it too.

The macro is based off of the c function::

    HYDAccessKeyPathInArray(NSArray *keyPaths)

As the name suggests, accepts an explicit array of keyPaths.


.. _HYDAccessKey:
.. _HYDKeyAccessor:

HYDAccessKey
============

This accessor provides KVC-styled access to objects. Like :ref:`HYDAccessKeyPath`,
this mapper will correctly convert boxed typed into their native c-types since
it internally uses ``-[valueForKey:]`` and ``-[setValue:forKey:]``.

If given ``[NSNull null]`` values, when setting values, then that **assignment
is considered a no-op**, not assigning to nil. This is because the accessor
cannot safely assign ``nil`` vs ``[NSNull null]`` (eg - property vs dictionary
key).

There is a macro to create this accessor:

    HYDAccessKey(...)

Which takes a variatic sequence of NSStrings that represent the keys to
walk. Giving multiple keyPaths will generate a large array value and the
expected input values when setting it too.

The macro is based off of the c function::

    HYDAccessKeyInArray(NSArray *keyPaths)

As the name suggests, accepts an explicit array of keys.


.. _HYDAccessDefault:

HYDAccessDefault
================

This is a helper function that maps to the default accessor that Hydrant's
mappers prefer. Handy if you need a default but don't have an opinion for your
own mappers. Hydrant currently maps this to :ref:`HYDAccessKeyPath`.

There are two variants::

    HYDAccessDefault(NSString *field)
    HYDAccessDefault(NSArray *fields)

Which currently ties to the same behavior as ``HYDAccessKeyPath``.
