Hydrant
=======

[![Build Status](https://travis-ci.org/jeffh/Hydrant.svg?branch=master)](https://travis-ci.org/jeffh/Hydrant)
[Documentation](http://hydrant.readthedocs.org)

A [simple](http://www.infoq.com/presentations/Simple-Made-Easy) object data mapper for Objective-C.
It aims to solve the data mapping problem well with a high degree of flexibility.

Mapping NSDictionaries to [Value Objects](https://github.com/jeffh/JKVValue) is boring
work! A lot of the work usually gets spread around in -[initWithDictionary:] methods
which has a few drawbacks:

 - They tightly couple your deserialization process to the value object. This can be extra confusing for deserializing the same object with a not-so-consistent backend API (which you may not control).
 - You tightly couple building an object graph (assuming your API returns one) into a specific value object.
 - You have to repeat the same, code in reverse when deserializing it back.
 - Convert various basic values into various native objective-c objects.
 - You have lots of laborious tests to cover various edge cases (you do test it right?)

Of course, then you want to convert them from one data format to another:

 - RFC3339 string should be converted into an `NSDate`
 - strings into NSURL
 - strings that need to be converted into numbers
 - a fixed set of strings as `NS_ENUM` values
 - etc.

But then you need to handle error cases. You don't want your app to crash, so:

 - Check you don't have `[NSNull null]` and/or `nil`
 - Check you have the correct type (before + after conversions)
 - Check if the key in a JSON object exists
 - Try and convert some json format into a specific object (eg - a string into an NSDate)
 - Possibly use a default value if any of the above cases fail
 - Do partial recovery, like excluding an object in an array of JSON objects if that one object is invalid.
 - Provide ways to extend to your custom parsing requirements

And that's what Hydrant aims to solve.

Of course, if you can fully control the API you hit, this library isn't much of a big deal.
But for developers that need to interact with APIs you don't directly control. Hydrant can help.

Installation
============

Like cocopods? Add this:

    pod "Hydrant", '~>1.0.0'

Or if you prefer living life on the edge:

    pod "Hydrant", :git => "https://github.com/jeffh/Hydrant.git"

Alternatively, git submodule add this project and adding it to your project.

Add the Hydrant static library for your dependencies or use the source directly.

Usage
=====

Read [Getting Started](http://hydrant.readthedocs.org/en/latest/getting_started.html).

