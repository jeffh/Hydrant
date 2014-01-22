JOM
===

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


Installation
------------

Currently installation is by git submodule add this project and adding it
to your XCodeProject (for now).

Add the JOM static library for your dependencies or use the source directly.

Usage
-----
