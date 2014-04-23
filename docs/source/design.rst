.. highlight:: objective-c

======
Design
======

This describes the internal design of Hydrant. Knowing the internal design
gives you the understanding how to extend Hydrant or contribute code.

The core the Hydrant's flexibility are its protocols. There are two primary
ones which most of the objects in Hydrant use to interact with each other.
There are specific expectations and assumptions of these protocools if you
choose to write code that conforms to these protocols.

Whenever possible, compose mappers than reimplementing features from existing
mappers. This also applies when writing your own mappers. For example,
:ref:`HYDMapKVCObject` doesn't do type checking, since :ref:`HYDMapType` does
that already. A facade object, :ref:`HYDMapObject` composes both of these
mappers to provide an object mapper that has type checking.

Philosophies
============

Hydrant has some opinions that are reflected in its code base and design -- some
more strongly than others. Individually, they are useful, but as more of
these are combined, they become greater than the sum of their parts.

.. _Composition:

Composition over Inheritance
----------------------------

Hydrant is a composition library. Inheritance is strongly discouraged when
building mappers or accessors. They tightly couple child classes and parent
classes, break encapsulation, and increase overhead when learning a code base.
A subclass implementation requires knowledge of the parent classes'
implementation too.

Hydrant uses subclasses as dictated by Apple's frameworks (eg -
NSFormatter or NSValueTransformer). Any other subclasses in Hydrant are
**quickfix temporary solutions** and are never to be considered public APIs.

Immutability over Mutability
----------------------------

Hydrant makes an unusual stance to hide all internal properties. Whenever
possible, Hydrant prefers immutability over mutation. This makes classes
significantly easier to consume and debug.

Having mutable properties also makes the classes less viable for being
shared across threads. Mutation can break assumptions about objects that
conform to an :ref:`abstraction <Abstractions>`.

.. _Abstractions:

Abstractions over Concretions
-----------------------------

Ideally, concrete classes should never have to know about each other by working
through a protocol. These protocols can be given on object construction to
provide flexibility. Protocols are also easy to :ref:`test <_TestDriven>`. They
provide a stronger assumption of having less intimate knowledge of the
collaborating object.

The only exception to this rule are `Value Objects`_ which should not perform
complex behavior, but be a vessel for storing data. :ref:`HYDError` is an
example of a value object.

Good abstractions can be utilized through the library and should thought through
carefully. Which leads to...

.. _`Value Objects`: http://martinfowler.com/bliki/ValueObject.html

Have Small Abstractions
-----------------------

The best abstractions are as narrow as possible, to allow the most flexibility
of an implementation. Conviences should be built on top of them but not be
included into the abstraction.

A large abstraction is usually indicative of multiple abstractions that need
to be split apart. For example, :ref:`HYDMapper` and :ref:`HYDAccessor` were
one protocol, which exposed itself because of the duplicated work required for
implementation of getting and setting data across various mappers. Splitting
this abstraction avoided other solutions: such as using inheritance or
copy-pasting similar implementations.

Abstractions are fractal, so it may not be immediately obvious that smaller
ones exist, but they do and provide a more flexible system in less code.

.. _TestDriven:

Test-Driven Code
----------------

While you may not agree with `TDD`_/`BDD`_, Hydrant should have thorough test
coverage for various scenarios. After all, nefarious input is being processed
by this library.

All public classes should have tests covering their proper behavior. Any bugs
fixed with associated tests that verify the bug.

.. _TDD: http://en.wikipedia.org/wiki/Test-driven_development
.. _BDD: http://en.wikipedia.org/wiki/Behavior-driven_development

.. _HYDMapper:

Mapper Protocol
===============

Let's look at the mapper protocol which is the foundation to Hydrant's design::

    @protocol HYDMapper <NSObject>

    - (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error;
    - (id<HYDMapper>)reverseMapper;

    @end

Using this protocol plus `object composition`_, provides a shared method for
mappers to compose with each other.

.. _object composition: http://en.wikipedia.org/wiki/Object_composition

Let's break it down by method -- along with their purposes and expectations::

    - (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error;

This method is where all the grunt work occurrs. Here a new object is created
from the source object. This also provides a method for returning errors that
should conform to Hydrant's error handling policies. This includes:

- Emitting fatal errors when mapping fails.
- Emitting non-fatal errors when an alternative mapping occurred.
- Including as much userInfo about the error (see constants).
- Returning nil if a fatal error occurs.

It is the responsibility of each mapper to **avoid throwing exceptions**. This
matches `Apple's convention`_ of `exceptions in Objective-C`_, where they should
be used to indicate programmer error.

For easy of discovery, many mappers will validate its construction instead of
possibly raising exceptions on ``-[objectFromSourceObject:error:]``.

.. _Apple's convention: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Exceptions/Exceptions.html
.. _exceptions in Objective-C: http://stackoverflow.com/questions/4648952/objective-c-exceptions

For Hydrant Mappers, any operation on the sourceObject should be treated
defensively. Doing work on a sourceObject **should never** raise an exception.
Even under ARC, memory leaks can occur when exceptions are caught since the
underlying libraries may not support the ``-fobjc-arc-exceptions`` flag.

That being said, exceptions can be raised if the definition of the resulting
object is improperly configured. For example, ``HYDObjectMapper`` will throw an
exception if the destination object is missing a key that is specified by the
Hydrant user.  But whenever possible, produce these exceptions as early as
possible (eg - on object construction time instead of when
``-[objectFromSourceObject:error:]`` is called).

The next method on ``HYDMapper`` are for compositions of mappers::

    - (id<HYDAccessor>)destinationAccessor;

This method returns an accessor instance for parent mappers (mappers that hold
this mapper). Accessors, which are described more in the later section, are an
abstraction to how to read and write values from an object. In this case, the
destinationAccessor is how the parent mapper should map the value. This method
exists for syntactic reasons of the DSL.

.. _HYDAccessor:

The Accessor Protocol
=====================

Some mappers use a smaller abstraction called accessors. Accessors describe
how to set and get values. Surprisingly, they are larger than the :ref:`HYDMapper`
protocol::

    @protocol HYDAccessor <NSObject>

    - (NSArray *)valuesFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error;
    - (HYDError *)setValues:(NSArray *)values onObject:(id)destinationObject;
    - (NSArray *)fieldNames;

    @end

There are currently two implementations of accessors: :ref:`HYDAccessKey` and
:ref:`HYDAccessKeyPath` which use KVC to set and get values off of objects.

The accessor protocol supports getting and setting multiple values at once. In
fact, both built-in Hydrant accessors support parsing multiple values. Allowing
mappers to process multiple values at once gives an opportunity to do value
joining (eg - joining a "date" and "time" field into a "datetime" field).

The method ``-[fieldNames]`` exists only for debuggability -- providing the
developer enough contextual information to location the exact mapper that failed
in a large composition of mappers. The values in this method is used by mappers
to populate Hydrant errors.

Accessors & Mappers
-------------------

Accessors can choose to emit errors like mappers, but the default
implementations existed prior to this feature and opt to return ``[NSNull null]``.
Hydrant mappers that treat ``nil`` and ``[NSNull null]`` the same. They also
extract values out of their resulting arrays if there is only one value for
easier composibility with other mappers.

Mappers will bubble up accessor errors to their consumers. The same rules about
fatalness apply here too -- fatal errors abort the entire parsing operation
while non-fatal errors indicate errors that could be recovered from.


.. _MappingDataStructure:

Mapping Data Structure
======================

Various mappers built on top of :ref:`HYDMapKVCObject` utilize an informal
data structure based format for describing field-to-field mapping which follows
the form of::

    @{<HYDAccessor>: <HYDMapping>}

Where's ``HYDMapping``? It's just a tuple, which is fancy for saying an array::

    @[<HYDMapper>, <HYDAccessor>]

So in summary, mapping dictionaries are just::

    @{<HYDAccessor1>: @[<HYDMapper>, <HYDAccessor2>]}

Which reads, map ``<HYDAccessor1>`` to ``<HYDAccessor2>`` using ``<HYDMapper>``.

To get this mapping into this form, it is first normalized by:

    - Converting all keys that are strings into :ref:`HYDAccessKeyPaths <HYDAccessKeyPath>`.
    - Converting all keys that are arrays into :ref:`HYDAccessKeyPaths <HYDAccessKeyPath>` with an array.
    - Converting all values that are strings into a mapping of :ref:`HYDMapIdentity` and :ref:`HYDKeyPathAccessors <HYDKeyPathAccessor>`.
    - Converting all values that are arrays into a mapping of :ref:`HYDMapIdentity` and :ref:`HYDKeyPathAccessors <HYDKeyPathAccessor>`.

And that's it! Anything else specific must be done explicitly using the
array-styled syntax. If you so choose, you can use your own tuple-like object
for the ``HYDMapping`` protocol.

.. _FunctionOverloading:

How do you have function overloading without being Objective-C++?
=================================================================

Hydrant makes use of a little known Clang-specific feature::

    __attribute__((overloadable))

This `overloadable attribute`_ allows basic C++ overloaded functions with some
notable exceptions::

    - It cannot overload with a zero-arity function.
    - Protocols are not part of the type dispatch -- so you cannot have two
      overloaded functions with different protocols

For convience, Hydrant uses the macro ``HYD_EXTERN_OVERLOADED`` to define
these functions::

    HYD_EXTERN_OVERLOADED
    id<HYDMapper> MyMapper(NSString *foo);

Since the custom attribute changes the compiled function name, **adding the
overloadable attribute to an existing will break existing consumers**. For iOS,
this is not usually a problem since recompilation is required for static
libraries. But for dynamic OSX libraries, this can be problematic.

.. _`overloadable attribute`: http://clang.llvm.org/docs/AttributeReference.html#overloadable


Trade-offs
==========

Every design and implementation has trade-offs. Anyone who tells you otherwise
is not giving the entire picture. Hydrant is no exception:

    - It is slower than naive parsing, because it's doing more validation checks
    - It is design for parsing data that you do not control, if you control the
      JSON API, it might not be necessary to use Hydrant
    - It provides no other features other serialization/deserialization, such as
      value objects, persistence, networking, etc.
