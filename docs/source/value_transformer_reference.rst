.. highlight:: objective-c

===========================
Value Transformer Reference
===========================

This is the reference documentation for all the `NSValueTransformers`_ that
Hydrant implements as conviences for you. Currently, these transformers are
intended to be used with :ref:`HYDMapReflectively`.

They are also publicly exposed if you need or prefer to use these classes
for other purposes.

.. _NSValueTransformers:  https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/NSFormatter_Class/Reference/Reference.html


.. _HYDBlockValueTransformer:

HYDBlockValueTransformer
========================

This value transformer is a simple abstraction to allow custom blocks instead of
having to implement a custom block value transformer.


.. _HYDIdentityValueTransformer:

HYDIdentityValueTransformer
===========================

This value transformer is a no-op, simply returning the value it has received.


.. _HYDReversedValueTransformer:

HYDReversedValueTransformer
===========================

This value transformer reverses another value transformer. The given value
transformer should be reverseable.


.. _HYDSnakeToCamelCaseValueTransformer:

HYDSnakeToCamelCaseValueTransformer
===================================

This value transformer converts snake case to camel case. You can optionally
specific if it is UpperCamelCase or lowerCamelCase.
