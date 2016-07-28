
============
Installation
============

If you're using `CocoaPods`_, you can pull in Hydrant by adding this to your
pod file::

    # this will pull any patch version with 'pod update'
    pod "Hydrant", '~>2.0.0'

Or submodule the project into your project::

    git submodule add https://github.com/jeffh/Hydrant.git <path/for/Hydrant>

And then add ``libHydrant`` to your dependencies and <./Hydrant/Public/> to
your header include path. At this point in time, importing individual
headers that are not ``Hydrant.h`` is not safe.

.. _CocoaPods: http://cocoapods.org
