
=======================
Introduction to Hydrant
=======================

This documents version 1.0 alpha of Hydrant.

Hydrant is a simple object serializer and data mapper library. It's secondary
goal is to handle invalid input gracefully without throwing exceptions.

If you want a jumpstart, check out the :doc:`Getting Started <getting_started>`
section.

Installation
============

If you're using `CocoaPods`_, you'll currently have to
pull in this dependency via github::

    pod 'Hydrant', :git => 'https://github.com/jeffh/Hydrant.git'

Or submodule the project into your project::

    git submodule add https://github.com/jeffh/Hydrant.git <path/for/Hydrant>

And then add ``libHydrant`` to your dependencies.

.. _CocoaPods: http://cocoapods.org

