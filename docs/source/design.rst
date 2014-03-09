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
``HYDObjectMapper`` does not do type checking, since ``HYDTypedMapper`` does
that already. A facade object, ``HYDTypedObjectMapper`` composes both of these
mappers to provide an object mapper that has type checking.

The Mapper Protocol
===================

Let's look at the mapper protocol which is the foundation to Hydrant's design::

    @protocol HYDMapper <NSObject>

    - (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error;
    - (id<HYDAccessor>)destinationAccessor;
    - (id<HYDMapper>)reverseMapperWithDestinationAccessor:(id<HYDAccessor>)destinationAccessor;

    @end

Using this protocol plus `object composition`_, provides a shared method for
mappers to compose with each other.

.. _object composition: http://en.wikipedia.org/wiki/Object_composition

Let's break it down method by method -- along with their purposes and
expectations::

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

Typical Mapper Implementations
==============================

TBD

The Accessor Protocol
=====================

TBD

Composition over Inheritance
============================

Hydrant is a composition library. Inheritance is strongly discouraged when
building mappers or accessors. They tightly couple child classes and parent
classes, break encapsulation, and increase overhead when learning/familiarizing
with a child class implementation (since it requires knowledge of the parent
classes' implementation too).

Internally, Hydrant uses subclasses dictated by Apple's frameworks (eg -
NSFormatter or NSValueTransformer). Any other subclasses in Hydrant are
**quickfix temporary solutions** and should not be considered public for
explicit use.

