JKSSerializer
=============

A simple data mapper / serializer for Objective-C.

Mapping NSDictionaries to [Value Objects](https://github.com/jeffh/JKVValue) is boring
work! A lot of the work usually gets spread around in -[initWithDictionary:] methods
which has a few drawbacks:

 - They tightly couple your deserialization process to the value object. This can be extra confusing for deserializing the same object with a not-so-consistent backend API (which you may not control).
 - You have to repeat the same, inverted code when deserializing it back.
 - You may want to support serialization into a variety of different formats


Installation
------------

Currently installation is by git submodule add this project and adding it
to your XCodeProject (for now).

Add the JKSSerializer static library for your dependencies or use the source directly.

Usage
-----
