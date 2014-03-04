.. Hydrant documentation master file, created by
   sphinx-quickstart on Sun Mar  2 15:14:23 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Documentation for Hydrant
=========================

This documents version 1.0 alpha of Hydrant.

Hydrant is a simple object serializer and data mapper library. It's secondary
goal is to handle invalid input gracefully without throwing exceptions.

If you want a jumpstart, check out the `Getting Started`_ section.

Quick Install
-------------

If you're using `CocoaPods <http://cocoapods.org>`_, you'll currently have to
pull in this dependency via github::

    pod 'Hydrant', :git => 'https://github.com/jeffh/Hydrant.git'

Or submodule the project into your project::

    git submodule add https://github.com/jeffh/Hydrant.git <path/for/Hydrant>


The Guide
=========

.. toctree::
   :maxdepth: 2

   getting_started
   api_reference
   troubleshooting
   changelog


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

