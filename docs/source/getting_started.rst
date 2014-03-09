.. highlight:: objective-c

===============
Getting Started
===============

Hydrant is designed to be highly flexible in converting a tree of objects into
another tree of objects. Yeah, that sounds pretty boring and stupid. But
deconstruct what that means.

You're provided the flexibility of converting any parse JSON (eg - structured
NSArrays, NSDictionaries) into Value Object graph for your application to use.
When doing this transformation, it can perform validations when performing
these operations.

Of course this doesn't have to be just JSON. Parsing XML or converting values
objects to your views and back are possible.

Enough talk, it's easier to see the usefulness with some code examples. Let's
jump right in.

The Problem
===========

Let's look at some json data we just parsed from `NSJSONSerialization <https://developer.apple.com/library/iOS/documentation/Foundation/Reference/NSJSONSerialization_Class/Reference/Reference.html>`_::

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

Using this example dictionary, how can we parse this with Hydrant?

Serializing with Hydrant
========================

Let's see how you can solve it via Hydrant::

    id<HYDMapper> mapper = HYDMapObject(HYDRootMapper, [NSDictionary class], [Person class],
                                        @{@"first_name": @"firstName",
                                          @"last_name": @"lastName",
                                          @"homepage": HYDMapStringToURL(@"homepage"),
                                          @"age": @"age",
                                          @"children": HYDMapArrayOf(HYDMapObject(@"children", [NSDictionary class], [Person class],
                                                                                  @{@"first_name": @"firstName",
                                                                                    @"last_name": @"lastName",
                                                                                    @"age": @"age"}));

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
from one object to another. In short, we're defining a schema of the JSON
structure we're expecting to parse. Let's break it down:

- The first ``HYDMapObject`` is a helper function that constructs an object for
  us to use. The function takes 4 arguments: an id, two classes, and a
  dictionary. The dictionary's keys correspond to the *first class* while the
  value corresponds to the *second class*. This defines a mapping from an
  NSDictionary to a Person class. So it's key will map in the same direction.
  The values can be strings or other objects that support the HYDMapper
  protocol.
- ``HYDRootMapper`` is a sentinel value to indicate this argument isn't used.
  Since the first argument is common to most of Hydrant's helper functions,
  this is a placeholder value to indicate nothing. It currently maps directly
  to ``nil``, but that may change in future versions.
- ``HHYDMapStringToURL`` is another helper function that constructs a HYDMapper
  object. It converts strings into NSURLs for our Person class.  It only takes
  an argument of where the URL result is stored -- to the homepage property of
  the Person class.
- ``HYDMapArrayOf`` is yet another helper function that constructs a HYDMapper
  compatible object. It takes an argument of another HYDMapper and uses it to
  parse an array of objects.
- The second ``HYDMapObject`` We've seen this again. But now the first argument
  becomes obvious, it provides the destination of the results of the operation
  -- in this example, to the children property.
- ``[mapper objectFromSourceObject:json error:nil]`` This actually does the
  conversion on the given JSON data structure and produces a Person class.  The
  mapper will produce an error if the parsing failed. When it produces a parse
  error is flexible, but we'll cover that shortly.
- ``[error isFatal]`` This checks the ``HYDError`` for fatalness. Hydrant has two
  notions of errors: fatal and non-fatal errors. Fatal errors are given when
  the object could not be produced under the given requirements.  Non-fatal
  errors indicate alternative parsing strategies have occurred to produce the
  object returned. We'll cover more of this shortly.

The ``mapper`` object can be reused for parsing that same JSON structure to
produce Person objects. So after the construction, it can be memoized.

For easy access, all helper functions that produce mappers are prefixed with
``HYDMap``.

Why not manully parse the JSON?
===============================

Let's take a short aside about the default go-to solution - parsing it
manually.  Here's a sample method to parse it manually::

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
one liked crashes: you, your customers, Apple reviewers. And writing all the
proper guard code starts becoming error-prone, boring, and adds a lot of noise
to your code.

Error Handling
==============

Of course if you don't know when Hydrant failed to parse something that's just
as unhelpful. So Hydrant mappers also return errors, which can be used to
handle errors when parsing the source object. There are three states after the
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

In practice, checking for ``-[HYDError isFatal]`` is usually the only check you
need to perform.

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

Marking fields as Optional
==========================

Most of time, we still want our users to still use the application despite some
invalid data. We can mark fields to tell Hydrant that some fatal errors are
actually non-fatal.

This produces the effect of having optional fields that are parsed when
possible or a fallback value is used instead.

The way to do this is with ``HYDMapOptionally``::

    id<HYDMapper> mapper = HYDMapObject(HYDRootMapper, [NSDictionary class], [Person class],
                                        @{@"first_name": @"firstName",
                                          @"last_name": @"lastName",
                                          @"homepage": HYDMapOptionally(HYDMapStringToURL(@"homepage")),
                                          @"age": HYDMapOptionally(@"age"),
                                          @"children": HYDMapArrayOf(HYDMapObject(@"children", [NSDictionary class], [Person class],
                                                                                  @{@"first_name": @"firstName",
                                                                                    @"last_name": @"lastName",
                                                                                    @"age": HYDMapOptionally(@"age")}));

Here we're making the age and homepage keys optional. Any invalid values will
produce nil or the zero-value:

    - If homepage isn't a valid NSURL, it is nil
    - If age isn't a valid number, it is 0

We can use this new mapper to selectively populate our array with values that
are parsable.  We can make our mapper ignore children objects that fail to
parse::

    id<HYDMapper> mapper = HYDMapArrayOf(HYDMapOptionally(HYDMapObject(HYDRootMapper, [NSDictionary class], [Person class],
                                                                       @{@"name": @"firstName"})));

    json = @[@{},
             @{"name": @"John"},
             @{"last": @"first"}];

    HYDError *error = nil;
    NSArray *people = [mapper objectFromSourceObject:json error:&error];
    
    people // => @[<Person: John>]
    error // => non-fatal error

But swapping to two map functions will change the behavior to optionally
dropping the array when any of the elements fail to parse::

    id<HYDMapper> mapper = HYDMapOptionally(HYDMapArrayOf(HYDMapObject(HYDRootMapper, [NSDictionary class], [Person class],
                                                                       @{@"name": @"firstName"})));

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

Since you've declared the relationship. You can use the mapper to convert the
person object back into JSON::

    id<HYDMapper> reversedMapper = [mapper reverseMapperWithDestinationAccessor:HYDRootMapper];
    id json = [reverseMapper objectFromSourceObject:john error:nil];

That will give us our JSON back. Easy as that!

Removing Boilerplate
====================

Pretty soon, you'll be typing a lot of these that map to dictionaries. So it is
implicit as the second argument to ``HYDMapObject``::


    id<HYDMapper> mapper = HYDMapObject(HYDRootMapper, [NSDictionary class], [Person class], ...);
    // can become (both are equivalent)
    id<HYDMapper> mapper = HYDMapObject(HYDRootMapper, [Person class], ...);

Likewise with arrays::

    // partial snippet from above
    @"children": HYDMapArrayOf(HYDMapObject(@"children", [NSDictionary class], [Person class], ...))
    // can become (both are equivalent)
    @"children": HYDMapArrayOfObjects(@"children", [Person class], ...)

So now we have this::

    id<HYDMapper> mapper = HYDMapObject(HYDRootMapper, [Person class],
                                        @{@"first_name": @"firstName",
                                          @"last_name": @"lastName",
                                          @"homepage": HYDMapStringToURL(@"homepage"),
                                          @"age": @"age",
                                          @"children": HYDMapArrayOfObjects(@"children", [Person class],
                                                                            @{@"first_name": @"firstName",
                                                                              @"last_name": @"lastName",
                                                                              @"age": @"age"}));

Using Reflection to Remove More Boilerplate
-------------------------------------------

If your JSON is well formed and just requires a little processing to map
directly to your objects, you can use ``HYDMapReflectively``, which will use
introspection of your class to determine how to map your values through.
Although some information is still required for various types::

    id<HYDMapper> childMapper = HYDMapReflectively(@"children", [Person class]).except(@[@"children"]);
    id<HYDMapper> mapper = HYDMapReflectively(HYDRootMapper, [Person class])
                            .overriding(@{@"children": HYDMapArrayOf(childMapper)});

.. warning:: The caveat for ``HYDMapReflectively`` is that you still need to be explicit on
             how to emit the JSON, which reflective mapper does not help you with.

The reflective mapper tries a bunch of strategies to parse the incoming data
in to something reasonable. For example, it tries various different NSDate
formats and permutations to convert an NSString into an NSDate.

Since the reflective mapper will need more information for emitting the various
types, we can specify like so::

    // let's say we changed this class to have a birthDate property
    @interface Person
    @property (copy, nonatomic) NSString *firstName;
    @property (copy, nonatomic) NSString *lastName;
    @property (strong, nonatomic) NSURL *homepage;
    @property (assign, nonatomic) NSInteger age;
    @property (strong, nonatomic) NSDate *birthDate;
    @end 

    id<HYDMapper> mapper = HYDMapReflectively(HYDRootMapper, [Person class])
                            .emit([NSDate class], HYDMapDateToString(HYDRootMapper, HYDDateFormatRFC3339));

This will explicitly tell Hydrant how to emit the given classes back. Otherwise
its behavior can be unexpected for certain classes. Read the documentation
about ``HYDReflectiveMapper``, which is the underlying implementation for more
details specific to this `facade`_ class.

.. _facade: http://en.wikipedia.org/wiki/Facade_pattern

