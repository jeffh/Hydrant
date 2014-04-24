.. highlight:: objective-c

========================
Writing Your Own Mappers
========================

Hydrant comes with a lot of mappers, but there will always be scenarios that
Hydrant cannot anticipate. Mappers are the ultimate method to extending the
features while still reusing as much as possible with Hydrant.

Before reading this, be sure to read the :ref:`HYDMapper` protocol and
:doc:`error handling <error_handling>`, specifically
:ref:`creating errors <CreatingHydrantErrors>`.

Thought Process
---------------

When writing a mapper, look to do the least amount of work possible. Allow the
composition of other mappers to achieve the bigger goal you're trying to solve:

    - Processing a collection? Can you use :ref:`HYDMapCollectionOf` instead?
    - Need to map objects? Can you compose with :ref:`HYDMapKVCObject`?

Even when implementing, feel free to use the existing mappers for implementation
details, :ref:`HYDMapReflectively` and :ref:`HYDMapObject` both compose
other mappers to achieve their work.

Type-checking (via ``-[isKindOfClass:]``) is a bit more sensitive. You should
do type checking to avoid crashing, but string type checks to specific concrete
classes should be considered carefully, because :ref:`HYDMapType` can cover
those use cases.

Raising Exceptions
------------------

While mappers should not raise exceptions for ``-[objectFromSourceObject:error]``,
it is perfectly acceptable to raise exceptions on mapper construction or
creating a reverse mapper for easier debuggability by the consumer of your
mapper.


Crafting your Implementation
----------------------------

When creating a new mapper, you should treat the two arguments you
receive very carefully:

    - ``sourceObject`` **can be any value**, so be sure that your mapper
      does not crash or throw exceptions when receiving ``nil``, ``[NSNull null]``,
      and unexpected object types.
    - ``error`` is an object pointer that may or may not be specified. Unlike
      some SDKs, **you should nil out the error pointer** if there are no
      errors.

If your mapper returns a fatal error, it is recommended to return ``nil``.
Using ``nil`` is not enough to indicate errors if parsing a source object to
return nil is intended behavior. Don't return ``[NSNull null]`` directly.

Closing Thoughts
----------------

Is the mapper you wrote generic? :doc:`Contribute <contributing>` it back to
Hydrant! Make sure it conforms to :doc:`Hydrant's design <design>` and is
tested.
