.. highlight:: objective-c

===========================
Value Transformer Reference
===========================

This is the reference documentation for all the `NSValueTransformers`_ that
Hydrant implements as conveniences for you. Currently, these transformers are
intended to be used with :ref:`HYDMapReflectively`.

They are also publicly exposed if you need or prefer to use these classes
for other purposes.

.. _NSValueTransformers:  https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/NSFormatter_Class/Reference/Reference.html


.. _HYDBlockValueTransformer:

HYDBlockValueTransformer
========================

This value transformer is a simple abstraction to allow custom blocks instead of
having to implement a custom value transformer. The Block Value Transformer
simply accepts two blocks: one for transforming and another for reverse
transforming.

Due to the limitation of the ``NSValueTransformer`` contract, the block
value transformer always returns ``YES`` for ``+[allowsReverseTransformation]``.

Example::

    HYDBlockValueTransformer *transformer = [[HYDBlockValueTransformer alloc] initWithBlock:^id(id value){
        return [value componentsSeparatedByString:@"-"];
    } reversedBlock:^id(id transformedValue){
        return [value componentsJoinedByString:@"-"];
    }];

    [transformer transformValue:@"foo-bar"] // => @[@"foo", @"bar"];
    [transformer reverseTransformedValue:@[@"foo", @"bar"]] // => @"foo-bar"


.. _HYDIdentityValueTransformer:

HYDIdentityValueTransformer
===========================

This value transformer is a no-op, simply returning the value it has received.
When used with :ref:`HYDMapReflectively`, this can be an easy way to make your
objects map directly to the source objects.

Example::

    HYDIdentityValueTransformer *transformer = [HYDIdentityValueTransformer new];

    [transformer transformValue:@"foo"] // => @"foo"
    [transformer reverseTransformedValue:@1] // => @1


.. _HYDReversedValueTransformer:

HYDReversedValueTransformer
===========================

This value transformer reverses another value transformer. Essentially, this
transformer converts:

    - ``-[transformValue:]`` into ``-[reverseTransformedValue:]``
    - and ``-[reverseTransformedValue:]`` into ``-[transformValue:]``

The given value transformer should be reversable.


.. _HYDCamelToSnakeCaseValueTransformer:

HYDCamelToSnakeCaseValueTransformer
===================================

This value transformer converts camel case to snake case. You can optionally
specific if it is UpperCamelCase or lowerCamelCase by specifying one of the
following enums::

    HYDCamelCaseLowerStyle // default when not specified
    HYDCamelCaseUpperStyle


This transformer expects ``NSStrings``. This is useful for
:ref:`HYDMapReflectively` to convert snake-cased JSON keys into the more
familiar Objective-C style of lower camel-case::

    HYDCamelToSnakeCaseValueTransformer *transformer = [[HYDCamelToSnakeCaseValueTransformer alloc] initWithStyle:HYDCamelCaseUpperStyle];

    [transformer transformValue:@"foo_bar"] // => @"FooBar"
    [transformer reverseTransformedValue:@"FooBar"] // => @"foo_bar"
