Hydrant
=======

A simple object data mapper for Objective-C.

Mapping NSDictionaries to [Value Objects](https://github.com/jeffh/JKVValue) is boring
work! A lot of the work usually gets spread around in -[initWithDictionary:] methods
which has a few drawbacks:

 - They tightly couple your deserialization process to the value object. This can be extra confusing for deserializing the same object with a not-so-consistent backend API (which you may not control).
 - You tightly couple building an object graph (assuming your API returns on) into a specific value object.
 - You have to repeat the same, code in reverse when deserializing it back.
 - Convert various basic values into various native objective-c objects.
 - You have lots of laborious tests to cover various edge cases (you do test it right?)

Of course, you need to convert them from one data format to another:

 - RFC3339 string should be converted into an `NSDate`
 - strings into NSURL
 - strings that need to be converted into numbers
 - a fixed set of strings as `NS_ENUM` values
 - etc.

But then you need to handle error cases. You don't want your app to crash, so:

 - Check you don't have `[NSNull null]`
 - Check you have the correct type
 - Check if the key in a JSON object exists
 - Try and convert some json format into a specific object (eg - a string into an NSDate)
 - Use a default value if any of the above cases fail
 - Do partial recovery, like excluding an object in an array of JSON objects if that one object is invalid.

Of course, if you can fully control the API you hit, this library isn't much of a big deal.

Installation
============

Currently installation is by git submodule add this project and adding it
to your XCodeProject (for now).

Add the Hydrant static library for your dependencies or use the source directly.

Usage
=====

Theory
------

The core of Hydrant are mappers. Lets look at `HYDMapper` protocol:

```
@protocol HYDMapper <NSObject>
// ... snip ...
- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error;
- (id<HYDMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey;
@end
```

These are the two primary methods for doing the data mapping work:

 - `objectFromSourceObject:error:` converts the sourceObject to a given object defined by each mapper class.
 - `reverseMapperwithDestinationKey:` produces a new mapper that can convert the returned object (from above) into the sourceObject.

In short, `HYDMapper` is the protocol to implement how *any object can be converted to any other object*.
Using a composition of mappers, we can produce an arbitrary schema to transform any object graph, such as JSON to Value Objects.

Building the Parser
-------------------

Lets parse this JSON:

```
{
    id: 2,
    name: "Andrew",
    people: [
        {id: 3, name: "Davis"},
        {id: 3, name: "Ken"}
    ]
}
```

We build a tree of mappers to handle this:

```
#import <Hydrant.h>

@interface Person // assuming implementation
@property (assign, nonatomic) NSInteger identifier;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSArray *friends;
@end

id<HYDMapper> personMapper = HYDMapObject(HYDRootMapper, [NSDictionary class], [Person class],
        @{@"id": @"identifier",
          @"name": @"firstName",
          @"people": HYDMapArrayOf(@"friends", [NSDictionary class], [Person class],
                                   @{@"id": @"identifier",
                                     @"name": @"firstName"})});
```

Then we can use our mapper to do the conversion

```
id json = ...;// our json object deserialized via NSJSONSerialization
HYDError *error = nil;
Person *person = [personMapper objectFromSourceObject:json error:&error];

// we'll get to why we need to use this method.
if ([error isFatal]) {
    NSLog(@"Failed to parse: %@", error);
    // handle error
} else {
    // use person...
}
```

That's it!. But what if the JSON is from a third party and is unreliable? Just add more information:

```
id<HYDMapper> personMapper = HYDMapObject(HYDRootMapper, [NSDictionary class], [Person class],
        @{@"id": HYDMapType(@"identifier", [NSNumber class]),
          @"name": HYDMapType(@"firstName", [NSString class]),
          @"people": HYDMapType(HYDMapArrayOf(@"friends", [NSDictionary class], [Person class],
                                              @{@"id": HYDMapType(@"identifier", [NSNumber class]),
                                                @"name": HYDMapType(@"firstName", [NSString class])}),
                                [NSArray class])});
```

Now all values are type checked before allowed through.

What if the `friends` key isn't always present? You can mark a field as optional.

```
id<HYDMapper> personMapper = HYDMapObject(HYDRootMapper, [NSDictionary class], [Person class],
        @{@"id": @"identifier",
          @"name": @"firstName",
          @"people": HYDMapOptionally(HYDMapArrayOf(@"friends", [NSDictionary class], [Person class],
                                                    @{@"id": @"identifier",
                                                      @"name": @"firstName"}))});
```

If the JSON is missing the `people` key, then the person is still returned, but the `error` is
still set. So we need to call `-[isFatal]` to check if the error caused a complete parsing
failure, as opposed to a gracefully degrated object. The error is still provided incase you
would like to log failures.

```
if ([error isFatal]) {
    // could not parse the object as defined in mappers
} else if (error) {
    // failed to parse some of the object, but still successful in producing an object (graph).
} else {
    // success
}
```

Extending
=========
