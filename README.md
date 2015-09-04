Quick-start guide
=================

This package consists of a template library. As such, all files that
you need to add to your code base are C++ header files.

The code makes extensive use of C++11 features, such as lambda
expressions. We have successfully tested the code base on GCC 4.9, but
expect that is also compatible with recent Clang.

What follows is a short guide to show you how to build one of the
example programs. First, clone this repository.

    $ git clone https://github.com/deepsea-inria/chunkedseq.git

Then, build an example program.

    $ make chunkedseq_1.exe
    g++ -std=c++11 -I ../include chunkedseq_1.cpp  -o chunkedseq_1.exe

Finally, run the example program.

    $ ./chunkedseq_1.exe 
    sum = 1000000000000

Full documentation
==================

See
[http://deepsea.inria.fr/chunkedseq/](http://deepsea.inria.fr/chunkedseq/).