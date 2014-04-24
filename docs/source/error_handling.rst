.. highlight:: objective-c

.. _HYDError:

=======================
Handling Hydrant Errors
=======================

When handling Hydrant errors, use the ``-[HYDError isFatal]`` method to check
if the received error is fatal. Fatal errors indicate that the resulting object
should not be used::

    HYDError *error = nil;
    id resultingObject = [mapper objectFromSourceObject:json error:&error];

    if ([error isFatal]) {
        // do error handling
    } else {
        // success
    }

If ``[error isFatal]`` is ``NO``, but there is a non-nil error, then a
non-fatal error has occurred. This is happens when a fallback parse option has
taken place. A simple example of this is with :ref:`HYDMapOptionally`::

    id<HYDMapper> mapper = HYDMapOptionallyTo(HYDMapStringToURL());

    id invalidURL = @1;

    HYDError *error = nil;
    id resultingObject = [mapper objectFromSourceObject:invalidURL error:&error];
    // error => non-fatal error
    // resultingObject => nil

This example above produces a non-fatal error with a resulting object of nil.
The non-fatal error reports the error that :ref:`HYDMapStringToURL` would.

Debugging Parse Errors
======================

Without exceptions, it becomes harder to track down the sources of errors. For
this reason, Hydrant errors store a signifcant amount of information for
debugability.

Currently HYDErrors provides a human-friendly output when using
``debugDescription`` or ``description``::

    (lldb) po error
    [FATAL] HYDErrorDomain (code=HYDErrorMultipleErrors) because "Multiple parsing errors occurred (fatal=1, total=2)"
    - Could not map from 'name.first' to 'firstName' (HYDErrorInvalidResultingObjectType)

The default description will emit all the fatal errors that have occurred when
parsing. Non-fatal errors are suppressed from output. If you want to see all
the errors, use ``-[HYDError fullDescription]``::

    (lldb) po [error fullDescription]
    [FATAL] HYDErrorDomain (code=HYDErrorMultipleErrors) because "Multiple parsing errors occurred (fatal=1, total=2)"
    - Could not map from 'name.first' to 'firstName' (HYDErrorInvalidResultingObjectType)
    - Could not map from 'name.last' to 'lastName' (HYDErrorInvalidResultingObjectType)

If you like trees, you can have a more classical-styled output using
``-[HYDError recursiveDescription]``, which prints a tree of fatal errors.

And there's a corresponding ``-[HYDError fullRecursiveDescription]`` which
emits a tree of all errors.

Reading Information from Hydrant Errors
=======================================

If you want more debugging information access the ``userInfo`` dictionary:

- ``HYDIsFatalKey`` returns an NSNumber indicating when the error is fatal or
  not. Fatal errors indicate the resulting object return should not be used.
- ``HYDUnderlyingErrorsKey`` returns all the child errors that contributes to
  this error.
- ``HYDSourceObjectKey`` returns the source object that caused the error. For
  child errors, this can be part of the original source object.
- ``HYDDestinationObjectKey`` returns destination object that caused the error.
  Most of the time this is nil unless mappers do post-object validation, such
  as :ref:`HYDTypedMapper`.
- ``HYDSourceAccessorKey`` returns the source accessor for accessing the source
  object value in question.
- ``HYDDestinationAccessorKey`` returns the destination accessor for the
  destination object. This is the intended destination of the resulting object.
  produced by this mapper.

``HYDError`` provides a helper methods for reading keys from ``userInfo`` more
easily::

    - (BOOL)isFatal;
    - (NSArray *)underlyingErrors;
    - (id)sourceObject;
    - (id)destinationObject;
    - (id<HYDAccessor>)sourceAccessor;
    - (id<HYDAccessor>)destinationAccessor;

.. warning:: It's worth noting that sourceObject and destinationObject could
             leak sensitive information. Be careful when you're sending
             HYDError's userInfo over the network or logging to disk.

.. _CreatingHydrantErrors:

Creating Hydrant Errors
=======================

If you're writing your own :ref:`HYDMapper` or :ref:`HYDAccessor` there are
also helper methods to construct conforming Hydrant errors::

    + (instancetype)errorWithCode:(NSInteger)code
                     sourceObject:(id)sourceObject
                   sourceAccessor:(id<HYDAccessor>)sourceAccessor
                destinationObject:(id)destinationObject
              destinationAccessor:(id<HYDAccessor>)destinationAccessor
                          isFatal:(BOOL)isFatal
                 underlyingErrors:(NSArray *)underlyingErrors;

This will properly construct the object with all possible information. While not
all the arguments are required. Providing more information will help with
tracing down parse errors. The only required parameters are ``code`` and
``isFatal`` -- any other parameter can accept ``nil``.

``underlyingErrors`` is an array of NSErrors, which can include other Hydrant
errors.

If your mapper contains other mappers, it can wrap errors with more
information::

    + (instancetype)errorFromError:(HYDError *)error
          prependingSourceAccessor:(id<HYDAccessor>)sourceAccessor
            andDestinationAccessor:(id<HYDAccessor>)destinationAccessor
           replacementSourceObject:(id)sourceObject
                           isFatal:(BOOL)isFatal;

This method uses existing values from the source error with potential overrides
or additions based on the context of the mapper's usage. Passing in ``nil``
will use the underlying error's values. Only ``error`` and ``isFatal`` are
required.

If your mapper uses multiple child mappers, you can create a HYDError with
multiple errors::

    + (instancetype)errorFromErrors:(NSArray *)errors
                       sourceObject:(id)sourceObject
                     sourceAccessor:(id<HYDAccessor>)sourceAccessor
                  destinationObject:(id)destinationObject
                destinationAccessor:(id<HYDAccessor>)destinationAccessor
                            isFatal:(BOOL)isFatal;

This will store the underlying errors for debugging via ``-[description]`` and
similar methods.
