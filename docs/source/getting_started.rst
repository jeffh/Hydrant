.. highlight:: objective-c

===============
Getting Started
===============

Hydrant is designed to be highly flexible in parsing JSON or any other
structured data (eg - structured NSArrays, NSDictionaries) into Value Objects
for your application to use. Hydrant can perform validations to ensure the
data coming in is what you expect when doing these transformations.

This doesn't have to be just JSON. Parsing XML or converting values
objects to your views and back is possible, but this tutorial will focus on
JSON.

Enough talk, it's easier to see the usefulness with some code examples.

The Problem
===========

Let's look at some json data we just parsed from `NSJSONSerialization`_::

    id json = @{
        @"first_name": @"John",
        @"last_name": @"Doe",
        @"homepage": @"http://example.com",
        @"age": @24,
        @"children": @[
            @{@"first_name": @"Ann",
              @"last_name": @"Doe",
              @"Age": 6},
            @{@"first_name": @"Bob",
              @"last_name": @"Doe",
              @"age": 6},
        ]
    };

.. _NSJSONSerialization: https://developer.apple.com/library/iOS/documentation/Foundation/Reference/NSJSONSerialization_Class/Reference/Reference.html

And we want to convert it to our person object::

    @interface Person : NSObject
    @property (copy, nonatomic) NSString *firstName;
    @property (copy, nonatomic) NSString *lastName;
    @property (strong, nonatomic) NSURL *homepage;
    @property (assign, nonatomic) NSInteger age;
    @property (copy, nonatomic) NSArray *children; // array of Person objects
    @end

    @implementation Person
    @end

How can we parse this with Hydrant?

Serializing with Hydrant
========================

Let's see how you can solve it via Hydrant::

    id<HYDMapper> mapper = HYDMapObject([NSDictionary class], [Person class],
                                        @{@"first_name": @"firstName",
                                          @"last_name": @"lastName",
                                          @"homepage": @[HYDMapStringToURL(), @"homepage"],
                                          @"age": @"age",
                                          @"children": @[HYDMapArrayOf(HYDMapObject([NSDictionary class], [Person class],
                                                                                    @{@"first_name": @"firstName",
                                                                                      @"last_name": @"lastName",
                                                                                      @"age": @"age"})
                                                         @"children"]);

    HYDError *error = nil;
    Person *john = [mapper objectFromSourceObject:json error:&error];
    if ([error isFatal]) {
        // do error handling
    } else {
        // use john ... it's valid
    }

At first glance, that's a lot of indentation! It's easy to break this into
several variables for readability. But we're doing this to easily see the
code flow of function calls for a function-by-function breakdown.

This is a declarative way to define how Hydrant should map fields
from one object to another. We're defining a schema of the JSON structure we're
expecting to parse. Let's break it down:

- The first :ref:`HYDMapObject` is a helper function that constructs an object for
  us to use. The function takes 4 arguments: an id, two classes, and a
  dictionary. The dictionary's keys correspond to the **first class** while the
  value corresponds to the **second class**. This defines a mapping from an
  NSDictionary to a Person class. So it's key will map in the same direction.
  The values can be strings or other objects that support the :ref:`HYDMapper`
  protocol.
- :ref:`HYDMapStringToURL` is another helper function that constructs a HYDMapper
  object. It converts strings into ``NSURLs`` for our ``Person`` class.
- :ref:`HYDMapArrayOf` is yet another helper function that constructs another
  ``HYDMapper`` object. It takes an argument of another ``HYDMapper`` and uses
  it to parse an array of objects.
- Now the second :ref:`HYDMapObject`. But now the first argument
  becomes obvious, it provides the destination of the results of the operation
  -- in this example, to the children property.
- ``[mapper objectFromSourceObject:json error:nil]`` This actually does the
  conversion on the given JSON data structure and produces a Person class.  The
  mapper will produce an error if the parsing failed. This method comes from
  the :ref:`HYDMapper` protocol.
- ``[error isFatal]`` This checks the ``HYDError`` for fatalness. Hydrant has two
  notions of errors: fatal and non-fatal errors. Fatal errors are given when
  the object could not be produced under the given requirements.  Non-fatal
  errors indicate alternative parsing strategies have occurred to produce the
  object returned. We'll cover more of this shortly.

The ``mapper`` object can be reused for parsing that same JSON structure to
produce Person objects. So after the construction, it can be memoized.

All helper functions that produce ``HYDMapper`` are prefixed with ``HYDMap`` for
easy auto-completing goodness.

Why not manully parse the JSON?
===============================

Let's take a short aside to talk about the go-to solution - parsing it manually.
Here's an example of parsing the JSON we got manually::

    Person *johnDoe = [Person new];
    johnDoe.firstName = json[@"first_name"];
    johnDoe.lastName = json[@"last_name"];
    johnDoe.age = [json[@"age"] integerValue];

    NSMutableArray *children = [NSMutableArray arrayWithCapacity:[json[@"children"] count]];
    for (NSDictionary *childJSON in json[@"children"]) {
        Person *child = [Person new];
        child.firstName = childJSON[@"first_name"];
        child.lastName = childJSON[@"last_name"];
        child.age = [childJSON[@"age"] integerValue];
        [children addObject:child];
    }

    johnDoe.children = children;

Not too bad. But what's are assumptions here? **We're assuming the structure of
the JSON.** Easy if you happen to control the source of this JSON, but what if
we don't? Someone could easily change the JSON to::

    id json = @[];

Or something less nefarious, but may potentially happen::

    id json = @{
        @"first_name": @"John",
        @"last_name": @"Doe",
        @"homepage": [NSNull null],
        @"age": [NSNull null],
        @"children": [NSNull null]
    };

That's now going to crash your program when you try to treat NSNull as another
object you expected (``NSArray``, ``NSNumber``, ``NSString``).  Last time I checked no
one liked crashes. And writing all the proper guard code starts becoming error-prone,
boring, and adds a lot of noise to your code.

But wait, you don't need to error check anything! Then you don't need to
use Hydrant. Simple as that. No hard feelings that you're not using my library.

Error Handling
==============

Of course, if you don't know when Hydrant failed to parse something that's just
as unhelpful. So Hydrant mappers return errors, which can be used to handle
errors when parsing the source object. There are three states after the
mapper parses the source object::

    HYDError *error = nil;
    Person *john = [mapper objectFromSourceObject:json error:&error];
    if ([error isFatal]) {
        // do error handling
    } else {
        if (error) {
            // log the non-fatal error.
        }
        // use john ... it's valid
    }

Checking for ``-[HYDError isFatal]`` is usually the only check you need to
perform in practice. Hydrant errors inherit from ``NSError``.

Hydrant errors contain a lot of state of the library when parsing fails. These
include the source object (or partial object being parsed), any internal
errors, other mapper errors, fatalness, and properties being mapped to and
from. They're all stored in userInfo, as ``HYDError`` just provides convenient
methods.

.. warning:: Since Hydrant errors store a lot of information about the source
             object, **you might leak sensitive information from the source
             object** (eg - user credentials) if you transfer the
             ``error.userInfo`` over the network.

So when would errors occur? Here's some examples from our mapper object we
defined:

- Hydrant fails to convert the incoming object to an NSURL for homepage, such
  as a trying to use a non-NSString.
- Any element in the incoming children array fails to parse.
- Any of the specified keys are nil or NSNull.
- Any of the properties that are set that aren't their corresponding property
  types (eg - "age" key is a string).

Read :doc:`error_handling` for more on this topic.

Marking fields as Optional
==========================

Most of time, we still want our users to still use the application despite some
invalid data. We can mark fields to tell Hydrant that some fatal errors are
actually non-fatal.

This produces the effect of having optional fields that are parsed or a fallback
value is used instead.

The way to do this is with :ref:`HYDMapOptionally`::

    id<HYDMapper> mapper = HYDMapObject[NSDictionary class], [Person class],
                                        @{@"first_name": @"firstName",
                                          @"last_name": @"lastName",
                                          @"homepage": @[HYDMapOptionallyTo(HYDMapStringToURL()), @"homepage"],
                                          @"age": @[HYDMapOptionally(), @"age"],
                                          @"children": @[HYDMapArrayOf(HYDMapObject([NSDictionary class], [Person class],
                                                                                    @{@"first_name": @"firstName",
                                                                                      @"last_name": @"lastName",
                                                                                      @"age": HYDMapOptionally(@"age")}))
                                                         @"children"];

Here we're making the **age** and **homepage** keys optional. Any invalid values
will produce nil or the zero-value:

    - If homepage isn't a valid NSURL, it is nil
    - If age isn't a valid number, it is 0

The format of the dictionary mapper ``HYDMapObject`` expects is::

    @{<KeyPathToRead>: @[<HYDMapper>, <KeyPathToWrite>],
      <KeyPathToRead>: <KeyPathToWrite>}

We can use this new mapper to selectively populate our array with values that
are parsable.  We can make our mapper ignore children objects that fail to
parse::

    id<HYDMapper> personMapper = HYDMapObject([NSDictionary class], [Person class],
                                              @{@"name": @"firstName"});
    id<HYDMapper> mapper = HYDMapArrayOf(HYDMapOptionallyTo(personMapper));

    json = @[@{},
             @{"name": @"John"},
             @{"last": @"first"}];

    HYDError *error = nil;
    NSArray *people = [mapper objectFromSourceObject:json error:&error];

    people // => @[<Person: John>]
    error // => non-fatal error

But swapping the two map functions will change the behavior to optionally
dropping the array when any of the elements fail to parse::

    id<HYDMapper> personMapper = HYDMapObject([NSDictionary class], [Person class],
                                              @{@"name": @"firstName"});
    id<HYDMapper> mapper = HYDMapOptionallyTo(HYDMapArrayOf(personMapper));

    json = @[@{},
             @{"name": @"John"},
             @{"last": @"first"}];

    HYDError *error = nil;
    NSArray *people = [mapper objectFromSourceObject:json error:&error];

    people // => nil
    error // => non-fatal error

The composition of these mappers provides the flexibility and power in Hydrant.

Converting it back to JSON
==========================

You can use the mapper to convert the person object back into JSON since we just
declaratively described the JSON structure::

    id<HYDMapper> reversedMapper = [mapper reverseMapper];
    id json = [reverseMapper objectFromSourceObject:john error:&err];

That will give us our JSON back. Easy as that!

Removing Boilerplate
====================

Soon, you'll be typing a lot of these maps to dictionaries. We can cut some of
the cruft we have to type. ``[NSDictionary class]`` is implicit as the second
argument to :ref:`HYDMapObject`::

    id<HYDMapper> mapper = HYDMapObject([NSDictionary class], [Person class], ...);
    // can is equivalent to
    id<HYDMapper> mapper = HYDMapObject([Person class], ...);

Likewise with arrays, you can merge :ref:`HYDMapObject` and :ref:`HYDMapArrayOf`
into :ref:`HYDMapArrayOfObjects`::

    HYDMapArrayOf(HYDMapObject([NSDictionary class], [Person class], ...))
    // can become
    HYDMapArrayOfObjects([Person class], ...)

So now we have this::

    id<HYDMapper> mapper = HYDMapObject([Person class],
                                        @{@"first_name": @"firstName",
                                          @"last_name": @"lastName",
                                          @"homepage": @[HYDMapStringToURL(), @"homepage"],
                                          @"age": @"age",
                                          @"children": @[HYDMapArrayOfObjects([Person class],
                                                                              @{@"first_name": @"firstName",
                                                                                @"last_name": @"lastName",
                                                                                @"age": @"age"}),
                                                         @"children"]});

But we can do even better.

Using Reflection to all the Boilerplate
---------------------------------------

If your JSON is well formed and just requires a little processing to map
directly to your objects, you can use :ref:`HYDMapReflectively`, which will use
introspection of your classes to determine how to map your values.
Although some information is still required for container types::

    HYDCamelToSnakeCaseValueTransformer *transformer = \
        [[HYDCamelToSnakeCaseValueTransformer alloc] init];
    id<HYDMapper> childMapper = HYDMapReflectively([Person class])
                                 .keyTransformer(transformer)
                                 .except(@[@"children"]);
    id<HYDMapper> mapper = HYDMapReflectively([Person class])
                            .keyTransformer(transformer)
                            .customMapping(@{@"children": @[HYDMapArrayOf(childMapper), @"children"]});

The ``mapper`` variable above will map incoming source objects by converting
snake cased keys to their camel cased variants to map properties together.

The reflective mapper tries a bunch of strategies to parse the incoming data
into something reasonable. For example, it tries various different NSDate
formats and permutations to convert an NSString into an NSDate.

The reflective mapper cannot predict how to convert it back to JSON since it
tries a number of strategies for parsing the JSON. We can specify it like so::

    // let's say we changed this class to have a birthDate property
    @interface Person
    // ...
    @property (strong, nonatomic) NSDate *birthDate;
    @end

    id<HYDMapper> mapper = HYDMapReflectively([NSDictionary class], [Person class])
                            .keyTransformer(snakeToCamelCaseTransformer)
                            .mapClass([NSDate class], HYDMapDateToString(HYDDateFormatRFC3339));

This will explicitly tell Hydrant how to map types to and from your source
object. Otherwise its behavior can be unexpected for certain classes. Read the
documentation about :ref:`HYDMapReflectively` for more details.

That's it! You might like to read up on some of the many mappers you can use.
But that's all there's to it!

Got some more complicated parsing you need to do? Check out the
:ref:`MappingTechniques` section for more details.
