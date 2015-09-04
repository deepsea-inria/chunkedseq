% Chunked sequence
% [Deepsea project](http://deepsea.inria.fr/)
% 3 September 2015

Introduction
============

This package provides a C++ template library that implements ordered,
in-memory containers that are based on a B-tree-like data structure.

Like STL deque, our chunkedseq data structure supports fast
constant-time update operations on the two ends of the sequence, and
like balanced tree structures, such as STL rope, our chunkedseq
structure supports efficient logarithmic-time split (at a specified
position) and merge operations. However, unlike prior data structures,
ours provides all of these operations simultaneously. Our [research
paper](http://deepsea.inria.fr/chunkedseq) presents evidence to back
these claims.

Key features of chunkedseq are:

- Fast constant-time push and pop operations on the two ends of the sequence.
- Logarithmic-time split at a specified position.
- Logarithmic-time concatenation.
- Familiar STL-style container interface.
- A *segment* abstraction to expose to clients of the chunked sequence
the contiguous regions of memory that exist inside chunks.

Provided container types
------------------------

- [Double-ended queue](#deque)
- [Stack](#stack)
- [Bag](#bag)
- [Associative map](#associative-map)

Advanced features
-----------------

- [Parallel processing](#parallel-processing)
- [Weighted container](#weighted-container)
- [STL-style iterator](#stl-iterator)
- [Segments](#segments)
- [Derived data structures by cached measurement](#cached-measurement)

Compatibility
-------------

This codebase makes extensive use of C++11 features, such as lambda
expressions. Therefore, we recommend a recent version of GCC or
Clang. We have tested the code on GCC v4.9.

Credits
-------

The [chunkedseq](http://deepsea.inria.fr/chunkedseq) package is
maintained by the members of the [Deepsea
Project](http://deepsea.inria.fr/).  Primary authors include:

- [Umut Acar](http://umut-acar.org)
- [Arthur Chargueraud](http://chargueraud.org)
- [Michael Rainey](http://gallium.inria.fr/~rainey).

Double-ended queue    {#deque}
==================

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
namespace pasl {
namespace data {
namespace chunkedseq {
namespace bootstrapped {

template <class Item>
class deque;

}}}}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The `deque` class implements a double-ended queue that, in addition to
fast access to both ends, provides logarithmic-time operations for
both weighted split and concatenation.

The deque interface implements much of the interface of the [STL
deque](http://www.cplusplus.com/reference/deque/deque/).  All
operations for accessing the front and back of the container (e.g.,
`front`, `push_front`, `pop_front`, etc.)  are supported.
Additionally, the deque supports splitting and concatenation in
logarithmic time and provides a random-access iterator.

Template parameters
-------------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
namespace pasl {
namespace data {
namespace chunkedseq {
namespace bootstrapped {

template <
  class Item,
  int Chunk_capacity = 512,
  class Cache = cachedmeasure::trivial<Item, size_t>,
  template <
    class Chunk_item,
    int Capacity,
    class Chunk_item_alloc=std::allocator<Item>
  >
  class Chunk_struct = fixedcapacity::heap_allocated::ringbuffer_ptrx,
  class Item_alloc = std::allocator<Item>
>
class deque;

}}}}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The signature above gives the complete list of the template parameters
of the `deque` class and the table below the meanings of each one.

+--------------------------------------+-----------------------------------+
| Template parameter                   | Description                       |
+======================================+===================================+
| [`Item`](#deque-item)                | Type of the objects to be stored  |
|                                      |in the container                   |
+--------------------------------------+-----------------------------------+
| [`Chunk_capacity`](#deque-capacity)  | Specifies capacity of chunks.     |
|                                      |                                   |
|                                      |                                   |
+--------------------------------------+-----------------------------------+
| [`Cache`](#deque-cache)              | Specifies the policy by which to  |
|                                      |cache measurements on interior     |
|                                      |chunks.                            |
+--------------------------------------+-----------------------------------+
| [`Chunk_struct`](#deque-chunk-struct)| Specifies the type of the chunks. |
|                                      |                                   |
|                                      |                                   |
+--------------------------------------+-----------------------------------+
| [`Item_alloc`](#deque-alloc)         | Allocator to be used by the       |
|                                      |container to construct and destruct|
|                                      |objects of type `Item`             |
+--------------------------------------+-----------------------------------+

Table: Template parameters for the `deque` class (short version).

### Item type {#deque-item}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
class Item;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Type of the elements.  Only if `Item` is guaranteed to not throw while
moving, implementations can optimize to move elements instead of
copying them during reallocations.  Aliased as member type
`deque::value_type`.

### Chunk capacity {#deque-capacity}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
int Chunk_capacity = 512;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The `Chunk_capacity` specifies the maximum number of items that can
fit in each chunk.

Although each chunk can store *at most* `Chunk_capacity` items, the
container can only guarantee that at most half of the cells of any
given chunk are filled.

### Cache type {#deque-cache}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
class Cache = cachedmeasure::trivial<Item, size_t>;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The `Cache` type specifies the strategy to be used internally by the
deque to maintain monoid-cached measurements of groups of items (see
[Cached measurement](#cached_measurement)).

### Chunk-struct type {#deque-chunk-struct}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
template <
  class Chunk_item,
  int Capacity,
  class Chunk_item_alloc=std::allocator<Item>
>
class Chunk_struct = fixedcapacity::heap_allocated::ringbuffer_ptrx;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The `Chunk_struct` type specifies the fixed-capacity ring-buffer
representation to be used for storing items (see [Fixed-capacity
buffers](#fixedcapacity)).

### Allocator type {#deque-alloc}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
class Item_alloc = std::allocator<Item>;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Type of the allocator object used to define the storage allocation
model. By default, the allocator class template is used, which defines
the simplest memory allocation model and is value-independent.
Aliased as member type `deque::allocator_type`.

Member types
------------

+-----------------------------------+-----------------------------------+
| Type                              | Description                       |
+===================================+===================================+
| `self_type`                       | Alias for the type of this        |
|                                   |container (e.g., `deque`, `stack`, |
|                                   |`bag`)                             |
+-----------------------------------+-----------------------------------+
| `value_type`                      | Alias for template parameter      |
|                                   |`Item`                             |
+-----------------------------------+-----------------------------------+
| `reference`                       | Alias for `value_type&`           |
+-----------------------------------+-----------------------------------+
| `const_reference`                 | Alias for `const value_type&`     |
+-----------------------------------+-----------------------------------+
| `pointer`                         | Alias for `value_type*`           |
+-----------------------------------+-----------------------------------+
| `const_pointer`                   | Alias for `const value_type*`     |
+-----------------------------------+-----------------------------------+
| `size_type`                       | Alias for `size_t`                |
+-----------------------------------+-----------------------------------+
| `segment_type`                    | Alias for                         |
|                                   |`pasl::data::segment<pointer>`     |
+-----------------------------------+-----------------------------------+
| `cache_type`                      | Alias for template parameter      |
|                                   |`Cache`                            |
+-----------------------------------+-----------------------------------+
| `measured_type`                   | Alias for                         |
|                                   |`cache_type::measured_type`        |
+-----------------------------------+-----------------------------------+
| `algebra_type`                    | Alias for                         |
|                                   |`cache_type::algebra_type`         |
+-----------------------------------+-----------------------------------+
| `measure_type`                    | Alias for                         |
|                                   |`cache_type::measure_type`         |
+-----------------------------------+-----------------------------------+
| [`iterator`](#deque-iter)         | Iterator                          |
+-----------------------------------+-----------------------------------+
| [`const_iterator`](#deque-iter)   | Const iterator                    |
+-----------------------------------+-----------------------------------+

Table: Member types of the `deque` class.

### Iterator {#deque-iter}

The types `iterator` and `const_iterator` are instances of the
[random-access
iterator](http://en.cppreference.com/w/cpp/concept/RandomAccessIterator)
concept. In addition to providing standard methods, our iterator
provides the methods that are specified in the following table.

+---------------------------------------+-----------------------------------+
| Method                                | Description                       |
+=======================================+===================================+
|[`size`](#iterator-size)               | Returns the number of preceding   |
|                                       |items                              |
|                                       |                                   |
+---------------------------------------+-----------------------------------+
| [`search_by`](#iterator-search-by)    | Search to some position guided by |
|                                       |a given predicate                  |
|                                       |                                   |
+---------------------------------------+-----------------------------------+
| [`get_segment`](#iterator-get-segment)| Returns the current segment       |
|                                       |                                   |
|                                       |                                   |
+---------------------------------------+-----------------------------------+

Table: Additional methods provided by the random-access iterator.

### Iterator size  {#iterator-size}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
size_type size() const;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns the number of items preceding and including the item pointed
to by the iterator.

***Complexity.*** Constant time.

### Search by predicate  {#iterator-search-by}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
template <class Predicate>
void search_by(const Predicate& p);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Moves the iterator to the first position `i` in the sequence for which
the call `p(m_i)` returns `true`, where `m_i` denotes the accumulated
cached measurement at position `i`.

***Complexity.*** Logarithmic time.

### Get enclosing segment {#iterator-get-segment}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
segment_type get_segment() const;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns the segment that encloses the iterator.

***Complexity.*** Constant time.


Constructors and destructors
----------------------------

+-----------------------------------+-----------------------------------+
| Constructor                       | Description                       |
+===================================+===================================+
| [empty container                  | constructs an empty container with|
|constructor](#deque-e-c-c) (default|no items                           |
|constructor)                       |                                   |
+-----------------------------------+-----------------------------------+
| [fill constructor](#deque-e-f-c)  | constructs a container with a     |
|                                   |specified number of copies of a    |
|                                   |given item                         |
+-----------------------------------+-----------------------------------+
| [copy constructor](#deque-e-cp-c) | constructs a container with a copy|
|                                   |of each of the items in the given  |
|                                   |container, in the same order       |
+-----------------------------------+-----------------------------------+
| [initializer list](#deque-i-l-c)  | constructs a container with the   |
|                                   |items specified in a given         |
|                                   |initializer list                   |
+-----------------------------------+-----------------------------------+
| [move constructor](#deque-m-c)    | constructs a container that       |
|                                   |acquires the items of a given      |
|                                   |container                          |
+-----------------------------------+-----------------------------------+
| [destructor](#deque-destr)        | destructs a container             |
+-----------------------------------+-----------------------------------+

Table: Constructors of the `deque` class.

### Empty container constructor {#deque-e-c-c}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
deque();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

***Complexity.*** Constant time.

Constructs an empty container with no items;

### Fill container {#deque-e-f-c}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
deque(long n, const value_type& val);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Constructs a container with `n` copies of `val`.

***Complexity.*** Time is linear in the size of the resulting
   container.

### Copy constructor {#deque-e-cp-c}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
deque(const deque& other);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Constructs a container with a copy of each of the items in `other`, in
the same order.

***Complexity.*** time is linear in the size of the resulting
   container.

### Initializer-list constructor {#deque-i-l-c}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
deque(initializer_list<value_type> il);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Constructs a container with the items in `il`.

***Complexity.*** Time is linear in the size of the resulting
   container.

### Move constructor {#deque-m-c}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
deque(deque&& x);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Constructs a container that acquires the items of `other`.

***Complexity.*** Constant time.

### Destructor {#deque-destr}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
~deque();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Destructs the container.

***Complexity.*** Time is linear and logarithmic in the size of the
   container.

Item access
-----------

+----------------------------+--------------------------------------+
| Operation                  | Description                          |
+============================+======================================+
| [`front`](#deque-frontback)| Access item on end.                  |
| [`back`](#deque-frontback) |                                      |
+----------------------------+--------------------------------------+
|[`operator[]`](#deque-i-o)  | Access member item                   |
|                            |                                      |
+----------------------------+--------------------------------------+
           
Table: Item accessors of the `deque` class.

### Front and back {#deque-frontback}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
value_type front() const;
value_type back() const;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns a reference to the last item in the container.

Calling this method on an empty container causes undefined behavior.

***Complexity.*** Constant time.

### Indexing operator {#deque-i-o}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
reference operator[](size_type i);
const_reference operator[](size_type i) const;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns a reference at the specified location `i`. No bounds check is
performed.

***Complexity.*** Logarithmic time.

Capacity
--------

+----------------------------+--------------------------------------+
| Operation                  | Description                          |
+============================+======================================+
| [`empty`](#deque-empty)    | Checks whether the container is      |
|                            |empty.                                |
+----------------------------+--------------------------------------+
|   [`size`](#deque-size)    | Returns the number of items.         |
|                            |                                      |
+----------------------------+--------------------------------------+

Table: Capacity methods of the `deque` class.

### Empty operator {#deque-empty}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
bool empty() const;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns `true` if the container is empty, `false` otherwise.

***Complexity.*** Constant time.

### Size operator {#deque-size}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
size_type size() const;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns the size of the container.

***Complexity.*** Constant time.

Iterators
---------

+----------------------------+--------------------------------------+
| Operation                  | Description                          |
+============================+======================================+
| [`front`](#deque-frontback)| Access item on end.                  |
| [`back`](#deque-frontback) |                                      |
+----------------------------+--------------------------------------+
|[`operator[]`](#deque-i-o)  | Access member item                   |
|                            |                                      |
+----------------------------+--------------------------------------+
| [`begin`](#deque-beg)      | Returns an iterator to the beginning |
| [`cbegin`](#deque-beg)     |                                      |
+----------------------------+--------------------------------------+
| [`end`](#deque-end)        | Returns an iterator to the end       |
| [`cend`](#deque-end)       |                                      |
+----------------------------+--------------------------------------+

Table: Iterators of the `deque` class.

### Iterator begin {#deque-beg}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
iterator begin() const;
const_iterator cbegin() const;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns an iterator to the first item of the container.

If the container is empty, the returned iterator will be equal to
end().

***Complexity.*** Constant time.

### Iterator end {#deque-end}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
iterator end() const;
const_iterator cend() const;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns an iterator to the element following the last item of the
container.

This element acts as a placeholder; attempting to access it results in
undefined behavior.

***Complexity.*** Constant time.

+-------------------------------------+--------------------------------------+
| Operation                           | Description                          |
+=====================================+======================================+
| [`push_front`](#deque-pushfrontback)| Adds items to the end                |
| [`push_back`](#deque-pushfrontback) |                                      |
+-------------------------------------+--------------------------------------+
| [`pop_front`](#deque-popfrontback)  | Removes items from the end           |
|  [`pop_back`](#deque-popfrontback)  |                                      |
+-------------------------------------+--------------------------------------+
| [`split`](#deque-split)             | Splits off part of the container     |
|                                     |                                      |
+-------------------------------------+--------------------------------------+
| [`concat`](#deque-concat)           | Merges contents of another container |
|                                     |                                      |
+-------------------------------------+--------------------------------------+
| [`clear`](#deque-clear)             | Erases contents                      |
|                                     |                                      |
+-------------------------------------+--------------------------------------+
| [`resize`](#deque-resize)           | Changes number of items stored       |
|                                     |                                      |
+-------------------------------------+--------------------------------------+
| [`swap`](#deque-swap)               | Swaps contents                       |
|                                     |                                      |
+-------------------------------------+--------------------------------------+

Table: Modifiers of the `deque` class.

### Push {#deque-pushfrontback}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
void push_front(const value_type& value);
void push_back(const value_type& value);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Prepends the given element `value` to the beginning of the container.

***Iterator validity.*** All iterators, including the past-the-end
iterator, are invalidated. No references are invalidated.

***Complexity.*** Constant time.

### Pop {#deque-popfrontback}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
value_type pop_back();
value_type pop_front();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Removes the last element of the container and returns the element.

Calling `pop_back` or `pop_front` on an empty container is undefined.

Returns the removed element.

***Complexity.*** Constant time.

### Split {#deque-split}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
void split(iterator position, self_type& other);    // (1)
void split(size_type position, self_type& other);   // (2)
template <class Predicate>
void split(const Predicate& p, self_type& other);   // (3)
template <class Predicate>
void split(const Predicate& p,                      // (4)
           reference middle_item,
           self_type& other);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. The container is erased after and including the item at the
specified position.

2. The container is erased after and including the item at
(zero-based) index `position`.

3. The container is erased after and including the item at the first
position `i` for which `p(m_i)` returns `true`, where `m_i` denotes
the accumulated cached measurement at position `i`.

4. The container is erased after the item at the first position `i`
for which `p(m_i)` returns `true`, where `m_i` denotes the accumulated
cached measurement at position `i`. The item at position `i` is also
erased, but in this case, the item is copied into the reference
`middle_item`.

The erased items are moved to the other container.

***Precondition.*** The `other` container is empty.

***Complexity.*** Time is logarithmic in the size of the container.

***Iterator validity.*** Invalidates all iterators.

### Concatenate {#deque-concat}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
void concat(self_type other);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Removes all items from `other`, effectively reducing its size to zero.

Adds items removed from `other` to the back of this container, after its
current last item.

***Complexity.*** Time is logarithmic in the size of the container.

***Iterator validity.*** Invalidates all iterators.

### Clear {#deque-clear}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
void clear();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Erases the contents of the container, which becomes an empty
container.

***Complexity.*** Time is linear in the size of the container.

***Iterator validity.*** Invalidates all iterators, if the size before
   the operation differs from the size after.

### Resize {#deque-resize}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
void resize(size_type n, const value_type& val); // (1)
void resize(size_type n) {                       // (2)
  value_type val;
  resize(n, val);
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Resizes the container to contain `n` items.

If the current size is greater than `n`, the container is reduced to
its first `n` elements.

If the current size is less than `n`,

1. additional copies of `val` are appended

2. additional default-inserted elements are appended

***Complexity.*** Let $m$ be the size of the container just before and
   $n$ just after the resize operation. Then, the time is linear in
   $\max(m, n)$.

***Iterator validity.*** Invalidates all iterators, if the size before
   the operation differs from the size after.

### Exchange operation {#deque-swap}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
void swap(deque& other);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Exchanges the contents of the container with those of `other`. Does
not invoke any move, copy, or swap operations on individual items.

***Complexity.*** Constant time.

Example: push and pop
---------------------

~~~~ {.cpp include="../examples/chunkedseq_2.example.deque_example"}
~~~~

[source](../examples/chunkedseq_2.cpp)

***Output***

    mydeque contains: 4 9 3 8 2 7 1 6 0 5

Example: split and concat
-------------------------


~~~~ {.cpp include="../examples/chunkedseq_5.example.split_example"}
~~~~

[source](../examples/chunkedseq_5.cpp)

***Output***

    Just after split:
    contents of mydeque: 0 1 8888
    contents of mydeque2: 9999 4 5
    Just after merge:
    contents of mydeque: 0 1 8888 9999 4 5
    contents of mydeque2:

Stack {#stack}
=====

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
namespace pasl {
namespace data {
namespace chunkedseq {
namespace bootstrapped {

template <class Item>
class stack;

}}}}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The stack is a container that supports the same set of
operations as the [deque](#deque), but has two key differences:

- Thanks to using a simpler stack structure to represent the
  chunks, the stack offers faster access to the back of the
  container and faster indexing operations than deque.
- Unlike deque, the stack cannot guarantee fast updates to
  the front of the container: each update operation performed on
  the front position can require at most `Chunk_capacity`
  items to be shifted toward to back.

Template interface
------------------

The complete template interface of the stack constructor is the same
as that of the deque constructor, except that the chunk structure is
not needed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
namespace pasl {
namespace data {
namespace chunkedseq {
namespace bootstrapped {

template <
  class Item,
  int Chunk_capacity = 512,
  class Cache = cachedmeasure::trivial<Item, size_t>,
  class Item_alloc = std::allocator<Item>
>
class stack;

}}}}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Example
-------

~~~~ {.cpp include="../examples/chunkedseq_3.example.stack_example"}
~~~~

[source](../examples/chunkedseq_3.cpp)

***Output***

    mystack contains: 4 3 2 1 0

Bag {#bag}
===

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
namespace pasl {
namespace data {
namespace chunkedseq {
namespace bootstrapped {

template <class Item>
class bagopt;

}}}}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Our bag container is a generic container that trades the guarantee of
order among its items for stronger guarantees on space usage and
faster push and pop operations than the corresponding properties of
the stack structure.  In particular, the bag guarantees that there are
no empty spaces in between consecutive items of the sequence, whereas
stack and deque can guarantee only that no more than half of the cells
of the chunks are empty.

Although our bag is unordered in general, in particular use cases,
order among items is guaranteed.  Order of insertion and removal of
the items is guaranteed by the bag under any sequence of push or pop
operations that affect the back of the container.  The split and
concatenation operations typically reorder items.

The container supports `front`, `push_front` and `pop_front`
operations for the sole purpose of interface compatibility.
These operations simply perform the corresponding actions
on the back of the container.

Template interface
------------------

The complete template interface of the bag is similar to that of
stack.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
namespace pasl {
namespace data {
namespace chunkedseq {
namespace bootstrapped {

template <
  class Item,
  int Chunk_capacity = 512,
  class Cache = cachedmeasure::trivial<Item, size_t>,
  class Item_alloc = std::allocator<Item>
>
class bagopt;

}}}}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Example
-------

~~~~ {.cpp include="../examples/chunkedseq_4.example.bag_example"}
~~~~

[source](../examples/chunkedseq_4.cpp)

***Output***

    mybag contains: 4 3 2 1 0

Associative map {#associative-map}
===============

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.cpp}
namespace pasl {
namespace data {
namespace map {

template <class Key,
          class Item,
          class Compare = std::less<Key>,
          class Key_swap = std_swap<Key>,
          class Alloc = std::allocator<std::pair<const Key, Item> >,
          int chunk_capacity = 8
>
class map;

}}}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Using the [cached-measurement feature](#cached-measurement) of our
chunked sequence structure, we have implemented asymptotically
efficient associative maps in the style of [STL
map](http://www.cplusplus.com/reference/map/map/). Our implementation
is, however, not designed to compete with highly optimized
implementations, such as that of STL. Rather, the main purpose of our
implementation is to provide an example of advanced use of cached
measurement so that others can apply similar techniques to build their
own custom data structures.

Our map interface implements only a subset of the [STL
interface](http://www.cplusplus.com/reference/map/map/). The
operations that we do implement have the same time and space
complexity as do the operations implemented by the STL
container. However, the constant factors imposed by our container may
be significantly larger than those of the STL container because our
structure is not specifically optimized for this use case.

Example: `insert`
-----------------

~~~~ {.cpp include="../examples/map_1.example.map_example"}
~~~~

[source](../examples/map_1.cpp)


***Output***

    mymap['a'] is an element
    mymap['b'] is another element
    mymap['c'] is another element
    mymap['d'] is 
    mymap now contains 4 elements.

Example: `erase`
----------------

~~~~ {.cpp include="../examples/map_2.example.map_example2"}
~~~~

[source](../examples/map_2.cpp)

***Output***

    f => 60
    e => 50
    d => 40
    a => 10

Parallel processing {#parallel-processing}
===================

The containers of the chunkedseq package are well suited to
applications which use fork-join parallelism: thanks to the
logarithmic-time split operations, chunkedseq containers can be
divided efficiently, and thanks to the logarithmic-time concatenate
operations, chunkedseq containers can be merged efficiently.
Moreover, chunkedseq containers can be processed efficiently in a
sequential fashion, thereby enabling a liberal programming style in
which sequential and parallel processing styles are combined
synergistically.  The following example programs deomonstrate this
style.

Remark:

> The data structures of the chunkedseq package are *not* concurrent
> data structures, or, put differently, chunkedseq data structures
> admit only single-threaded update operations.

Remark:

> The following examples are evidence that this single-threading
> restriction does *not* necessarily limit parallelism.

Example: `pkeep_if`
-------------------

To see how our deque can be used for parallel processing, let us
consider the following program, which constructs the subsequence of a
given sequence, based on selections taken by a client-supplied
predicate function.  Assuming fork-join parallel constructs, such as
Cilk's `spawn` and `sync`, the selection and build process of the
`pkeep_if` function can achieve a large (in fact, unbounded) amount of
parallelism thanks to the fact that the span of the computation is
logarithmic in the size of the input sequence.  Moreover, `pkeep_if`
is *work efficient* thanks to the fact that the algorithm takes linear
time in the size of the input sequence (assuming, of course, that
the client-supplied predicate takes constant time).

~~~~ {.cpp include="../examples/chunkedseq_1.example.chunkedseq_example1"}
~~~~

[source](../examples/chunkedseq_1.cpp)


***Output***

    sum = 1000000000000

Example: `pcopy`
---------------

This algorithm implements a parallel version of
[std::copy](http://en.cppreference.com/w/cpp/algorithm/copy).  Note,
however, that the two versions differ slightly: in our version, the
type of the destination parameter is a reference to the destination,
whereas the corresponding type in std::copy is instead an iterator
that points to the beginning of the destination container.

~~~~ {.cpp include="../examples/chunkedseq_6.example.pcopy_example"}
~~~~

[source](../examples/chunkedseq_6.cpp)


***Output***

    mydeque2 contains: 0 1 2 3 4 5

Example: `pcopy_if`
-------------------

This algorithm implements a parallel version of
[std::copy_if](http://en.cppreference.com/w/cpp/algorithm/copy).  Just
as before, our implementation uses a type for the third parameter that
is different from the corresponding third parameter of the STL
version.

~~~~ {.cpp include="../examples/chunkedseq_7.example.pcopy_if_example"}
~~~~

[source](../examples/chunkedseq_7.cpp)

***Output***

    mydeque2 contains: 0 2 4

Weighted container {#weighted-container}
==================

The `chunkedseq` containers can easily generalize to *weighted
containers*.  A weighted container is a container that assigns to each
item in the container an integral weight value.  The weight value is
typically expressed as a weight function that is defined by the client
and passed to the container via template argument.

The purpose of the weight is to enable the client to use the
weighted-split operation, which divides the container into two pieces
by a specified weight.  The split operation takes only logarithmic
time.

Example: split sequence of strings by length
--------------------------------------------

The following example program demonstrates how one can use weighted
split to split a sequence of string values based on the number of
even-length strings.  In this case, our split divides the sequence
into two pieces so that the first piece goes into `d` and the second
to `f`.  The split function specifies that `d` is to receive the first
half of the original sequence of strings that together contain half of
the total number of even-length strings in the original sequence; `f`
is to receive the remaining strings.  Because the lengths of the
strings are cached internally by the weighted container, the split
operation takes logarithmic time in the number of strings.

~~~~ {.cpp include="../examples/weighted_split.example.weighted_split_example"}
~~~~

[source](../examples/weighted_split.cpp)

***Output***

    nb even strings: 6
    d =
    Let's divide this

    f =
    sequence of strings into two pieces

STL-style iterator {#stl-iterator}
==================

Our deque, stack and bag containers implement the [random-access
iterators](#deque-iterator) in the style of [STL's random-access
iterators](http://www.cplusplus.com/reference/iterator/RandomAccessIterator/).

Example
-------

~~~~ {.cpp include="../examples/iterator_1.example.iterator_example"}
~~~~

[source](../examples/iterator_1.cpp)

***Output***

    mydeque contains: 0 1 2 3 4

Segments {#segments}
======== 

In this package, we use the term segment to refer to pointer values
which reference a range in memory.  We define two particular forms of
segments:

- A *basic segment* is a value which consists of two pointers, namely
  `begin` and `end`, that define the right-open interval, `(begin,
  end]`.
- An *enriched segment* is a value which consists of a basic segment,
  along with a pointer, namely `middle`, which points at some location
  in between `begin` and `end`, such that `begin <= middle < end`.

The following class defines a representation for enriched segments.

~~~~ {.cpp include="../include/segment.example.segment"}
~~~~

[source](../examples/segment.hpp)

Example
-------

~~~~ {.cpp include="../examples/segment_1.example.segment_example"}
~~~~

[source](../examples/segment_1.cpp)

***Output***

    mydeque contains: 0 1 2 3 4 5
    the segment which contains mydeque[3] contains: 2 3
    mydeque[3]=3

Cached measurement {#cached-measurement}
==================

This documentation covers essential concepts that are needed to
implement custom data structures out of various instantiations of the
chunkedseq structure.
Just like the Finger Tree of Hinze and Patterson, the chunkedseq
can be instantiated in certain ways to yield asymptotically efficient
data structures, such as associative maps, priority queues, weighted
sequences, interval trees, etc.
A summary of these ideas that is presented in greater detail can be
find in the [original publication on finger
trees](http://www.soi.city.ac.uk/~ross/papers/FingerTree.html) and in
a [blog
post](http://apfelmus.nfshost.com/articles/monoid-fingertree.html).

In this tutorial, we present the key mechanism for building
derived data structures: *monoid-cached measurement*.
We show how to use monoid-cached measurements to implement a powerful
form of split operation that affects chunkedseq containers.
Using this split operation, we then show how to apply our
cached measurement scheme to build two new data structures:

- weighted containers with weighted splits
- asymptotically efficient associative map containers in the style of
  [std::map](http://www.cplusplus.com/reference/map/map/)


Taking measurements
-------------------

Let $S$ denote the type of the items contained by the chunkedseq
container and $T$ the type of the cached measurements.
For example, suppose that we want to define a weighted chunkedseq
container of `std::string`s for which the weights have type
`weight_type`. Then we have: $S = \mathtt{std::string}$ and $T =
\mathtt{weight\_type}$.
How exactly are cached measurements obtained?
The following two methods are the ones that are used by our C++
package.

### Measuring items individually

A *measure function* is a function $m$ that is provided by the client;
the function takes a single item and returns a single measure value:
$m(s) : S \rightarrow T$.

### Example: the "size" measure

Suppose we want to use our measurement to represent the number of
items that are stored in the container. We call this measure the *size
measure*.  The measure of any individual item always equals one:
$\mathtt{size}(s) : S \rightarrow \mathtt{long} = 1$.

### Example: the "string-size" measure

The string-size measurement assigns to each item the weight equal to
the number of characters in the given string:
$\mathtt{string\_size}(str) : \mathtt{string} \rightarrow
\mathtt{long} = str.\mathtt{size}()$.

### Measuring items in contiguous regions of memory

Sometimes it is convenient to have the ability to compute, all at
once, the combined measure of a group of items that is referenced by a
given "basic" [segment](@ref segments).  For this reason, we require
that, in addition to $m$, each measurement scheme provides a
segment-wise measure operation, namely $\mathbb{m}$, which takes the pair
of pointer arguments $begin$ and $end$ which correspond to a basic
segment, and returns a single measured value: $\mathbb{m}(begin, end) :
(S^\mathtt{*}, S^\mathtt{*}) \rightarrow T$.

The first and second arguments correspond to the range in memory
defined by the segment $(begin, end]$.
The value returned by $\mathbb{m}(begin, end)$ should equal the sum of the
values $m(\mathtt{*}p)$ for each pointer $p$ in the range
$(begin, end]$.

#### Example: segmented version of our size measurement

This operation is simply $\mathbb{m}(begin, end) = |end-begin|$, 
where our segment is defined by the sequence of items represented
by the range of pointers $(begin, end]$.

### The measure descriptor

The *measure descriptor* is the name that we give to the C++ class
that describes a given measurement scheme.
This interface exports deinitions of the following
types:

Type                   | Description
-----------------------|----------------------------------------------------
`value_type`           | type $S$ of items stored in the container
`measured_type`        | type $T$ of item-measure values

And this interface exports definitions of the following methods:

Members                                                                    | Description
---------------------------------------------------------------------------|------------------------------------------------
`measured_type operator()(const value_type& v)`                            | returns $m(\mathtt{v})$
`measured_type operator()(const value_type* begin, const value_type* end)` | returns $\mathbb{m}(\mathtt{begin}, \mathtt{end})$

#### Example: trivial measurement

Our first kind of measurement is one that does nothing except make
fresh values whose type is the same as the type of the second template
argument of the class.

~~~~ {.cpp include="../include/measure.example.trivial"}
~~~~

[source](../include/measure.hpp)


The trivial measurement is useful in situations where cached
measurements are not needed by the client of the chunkedseq. Trivial
measurements have the advantage of being (almost) zero overhead
annotations.

### Example: weight-one (uniformly sized) items

This kind of measurement is useful for maintaining fast access to the
count of the number of items stored in the container.

~~~~ {.cpp include="../include/measure.example.uniform"}
~~~~

[source](../include/measure.hpp)

#### Example: dynamically weighted items

This technique allows the client to supply to the internals of the
chunkedseq container an arbitrary weight function. This
client-supplied weight function is passed to the following class by
the third template argument.

~~~~ {.cpp include="../include/measure.example.weight"}
~~~~

[source](../include/measure.hpp)

#### Example: combining cached measurements

Often it is useful to combine meaurements in various
configurations. For this purpose, we define the measured pair, which
is just a structure that has space for two values of two given
measured types, namely `Measured1` and `Measured2`.

~~~~ {.cpp include="../include/measure.example.measured_pair"}
~~~~

[source](../include/measure.hpp)

The combiner measurement just combines the measurement strategies of
two given measures by pairing measured values.

~~~~ {.cpp include="../include/measure.example.combiner"}
~~~~

[source](../include/measure.hpp)

Using algebras to combine measurements
--------------------------------------

Recall that a *monoid* is an algebraic structure that consists
of a set $T$, an associative binary operation $\oplus$ and an identity
element $\mathbf{I}$. That is, $(T, \oplus, \mathbf{I})$ is a monoid
if:

- $\oplus$ is associative: for every $x$, $y$ and $z$ in $T$, 
  $x \oplus (y \oplus z) = (x \oplus y) \oplus z$.
- $\mathbf{I}$ is the identity for $\oplus$: for every $x$ in $T$,
  $x \oplus \mathbf{I} = \mathbf{I} \oplus x$.

Examples of monoids include the following:

- $T$ = the set of all integers; $\oplus$ = addition; $\mathbf{I}$
  = 0
- $T$ = the set of 32-bit unsigned integers; $\oplus$ = addition
  modulo $2^{32}$; $\mathbf{I}$ = 0
- $T$ = the set of all strings; $\oplus$ = concatenation;
  $\mathbf{I}$ = the empty string

A *group* is a closely related algebraic structure. Any monoid
is also a group if the monoid has an inverse operation $\ominus$:

- $\ominus$ is inverse for $\oplus$: for every $x$ in $T$,
  there is an item $y = \ominus x$ in $T$, such that $x \oplus y
  = \mathbf{I}$.

### The algebra descriptor

We require that the descriptor export a binding to the type of the
measured values that are related by the algebra.

Type                   | Description
-----------------------|-------------------------------------------------------------
`value_type`           | type of measured values $T$ to be related by the algebra

We require that the descriptor export the following members. If
`has_inverse` is false, then it should be safe to assume that the
`inverse(x)` operation is never called.

Static members                                 | Description
-----------------------------------------------|-----------------------------------
const bool has_inverse                         | `true`, iff the algebra is a group
value_type identity()                          | returns $\mathbf{I}$
value_type combine(value_type x, value_type y) | returns `x` $\oplus$ `y`
value_type inverse(value_type x)               | returns $\ominus$ `x`

#### Example: trivial algebra

The trivial algebra does nothing except construct new identity
elements.

~~~~ {.cpp include="../include/algebra.example.trivial"}
~~~~

[source](../include/algebra.hpp)

#### Example: algebra for integers

The algebra that we use for integers is a group in which the identity
element is zero, the plus operator is integer addition, and the minus
operator is integer negation.

~~~~ {.cpp include="../include/algebra.example.int_group_under_addition_and_negation"}
~~~~

[source](../include/algebra.hpp)

### Example: combining algebras

Just like with the measurement descriptor, an algebra descriptor can
be created by combining two given algebra descriptors pairwise.

~~~~ {.cpp include="../include/algebra.example.combiner"}
~~~~

[source](../include/algebra.hpp)

### Scans

A *scan* is an iterated reduction that maps to each item $v_i$ in a
given sequences of items $S = [v_1, v_2, \ldots, v_n]$ a single
measured value $c_i = \mathbf{I} \oplus m(v_1) \oplus m(v_2) \oplus
\ldots \oplus m(v_i)$, where $m(v)$ is a given measure function.
For example, consider the "size" (i.e., weight-one) scan, which is
specified by the use of a particular measure function:
$m(v) = 1$.
Observe that the size scan gives the positions of the items in the
sequence, thereby enabling us later on to index and to split the
chunkedseq at a given position.

For convenience, we define scan formally as follows. The operator
returns the combined measured values of the items in the range
of positions $[i, j)$ in the given sequence $s$.

$M_{i,j}     :  \mathtt{Sequence}(S) \rightarrow T$

$M_{i,i}(s)  =  \mathbf{I}$

$M_{i,j}(s)  =  m(s_i) \oplus m(s_{i+1}) \oplus \ldots \oplus m(s_{j}) \, \mathrm{if} \, i < j$

### Why associativity is necessary

The cached value of an internal tree node $k$ in the chunkedseq
structure is computed by $M_{i,j}(s)$, where $s = [v_i, \ldots,
v_j]$ represents a subsequence of values contained in the chunks of
the subtree below node $k$. When this reduction is performed by
the internal operations of the chunkedseq, this expression is broken
up into a set of subexpressions, for example: $((m(v_i) \oplus
m(v_{i+1})) \oplus (m(v_{i+2}) \oplus m(v_{i+3}) \oplus (m(v_{i+4})
\oplus m(v_{i+5}))) ... \oplus m(v_j))$. The partitioning into
subexpressions and the order in which the subexpressions are combined
depends on the particular shape of the underlying
chunkedseq. Moreover, the particular shape is determined uniquely by
the history of update operations that created the finger tree. As
such, we could build two chunkedseqs by, for example, using different
sequences of push and pop operations and end up with two different
chunkedseq structures that represent the same sequence of items. Even
though the two chunkedseqs represent the same sequence, the cached
measurements of the two chunkedseqs are combined up to the root of the
chunkedseq by two different partitionings of combining
operations. However, if $\oplus$ is associative, it does not
matter: regardless of how the expression are broken up, the cached
measurement at the root of the chunkedseq is guaranteed to be the same
for any two chunkedseqs that represent the same sequence of items.
Commutativity is not necessary, however, because the ordering of the
items of the sequence is respected by the combining operations
performed by the chunkedseq.

### Why the inverse operation can improve performance

Suppose we have a cached measurement $C = M_{i,j}(s)$ , where $s
= [v_i, \ldots, v_j]$ represents a subsequence of values contained
in the same chunk somewhere inside our chunkedseq structure. Now,
suppose that we wish to remove the first item from our sequence of
measurements, namely $v_i$. On the one hand, without an inverse
operation, and assuming that we have not cached partial sums of
$C$, the only way to compute the new cached value is to recompute
$(m(v_{i+1}) \oplus ... \oplus m(v_j))$. On the other hand, if the
inverse operation is cheap, it may be much more efficient to instead
compute $\ominus m(v_i) \oplus C$.

Therefore, it should be clear that using the inverse operation can
greatly improve efficiency in situations where the combined cached
measurement of a group of items needs to be recomputed on a regular
basis. For example, the same situation is triggered by the pop
operations of the chunks stored inside the chunkedseq structure. On
the one hand, by using inverse, each pop operation requires only a few
additional operations to reset the cached measured value of the
chunk. On the other, if inverse is not available, each pop operation
requires recomputing the combined measure of the chunk, which although
constant time, takes time proportion with the chunk size, which can be
a fairly large fixed constant, such as 512 items.  As such,
internally, the chunkedseq operations use inverse operations whenever
permitted by the algebra (i.e., when the algebra is identified as a
group) but otherwise fall back to the most general strategy when the
algebra is just a monoid.

Defining custom cached-measurement policies
-------------------------------------------

The cached-measurement policy binds both the measurement scheme and
the algebra for a given instantiation of chunkedseq.  For example, the
following are cached-measurement policies:

- nullary cached measurement: $m(s) = \emptyset$; $\mathbb{m}(v) =
  \emptyset$; $A_T = (\mathcal{P}(\emptyset), \cup, \emptyset,
  \ominus )$, where $\ominus \emptyset = \emptyset$
- size cached measurement: $m(s) = 1$; $\mathbb{m}(v) = |v|$; $A_T =
  (\mathtt{long}, +, 0, \ominus )$
- pairing policies (monoid): for any two cached-measurement
  policies $m_1$; $\mathbb{m_1}$; $A_{T_1} = (T_1, \oplus_1,
  \mathtt{I}_1)$ and $m_2$; $\mathbb{m_2}$; $A_{T_2} = (T_2, \oplus_2,
  \mathtt{I}_2)$, $m(s_1, s_2) = (m_1(s_1), m_2(s_2))$; $\mathbb{m}(v_1,
  v_2) = (\mathbb{m_1}(v_1), \mathbb{m_2}(v_2))$; $A = (T_1 \times T_2,
  \oplus, (\mathtt{I}_1, \mathtt{I}_2))$ is also a cached-measurement
  policy, where $(x_1, x_2) \oplus (y_1, y_2) = (x_1 \oplus y_1, x_2
  \oplus y_2)$
- pairing policies (group): for any two cached-measurement
  policies $m_1$; $\mathbb{m_1}$; $A_{T_1} = (T_1, \oplus_1,
  \mathtt{I}_1, \ominus_1)$ and $m_2$; $\mathbb{m_2}$; $A_{T_2} =
  (T_2, \oplus_2, \mathtt{I}_2, \ominus_2)$, $m(s_1, s_2) =
  (m_1(s_1), m_2(s_2))$; $\mathbb{m}(v_1, v_2) = (\mathbb{m_1}(v_1),
  \mathbb{m_2}(v_2))$; $A = (T_1 \times T_2, \oplus, (\mathtt{I}_1,
  \mathtt{I}_2), \ominus)$ is also a cached-measurement policy,
  where $(x_1, x_2) \oplus (y_1, y_2) = (x_1 \oplus y_1, x_2 \oplus
  y_2)$ and $\ominus(x_1, x_2) = (\ominus_1 x_1,
  \ominus_2 x_2)$
- pairing policies (mixed): if only one of two given
  cached-measurement policies is a group, we demote the group to a
  monoid and apply the pairing policy for two monoids

Remark:

> To save space, the chunkedseq structure can be instantiated with the
> nullary cached measurement alone. No space is taken by the cached
> measurements in this configuration because the nullary measurement
> takes zero bytes. However, the only operations supported in this
> configuration are push, pop, and concatenate. The size cached
> measurement is required by the indexing and split operations. The
> various instantiations of chunkedseq, namely deque, stack and bag
> all use the size measure for exactly this reason.

### The cached-measurement descriptor

The interface exports four key components: the type of the items in
the container, the type of the measured values, the measure function
to gather the measurements, and the algebra to combine measured
values.

Type                   | Description
-----------------------|--------------------------------------------
`measure_type`         | type of the measure descriptor
`algebra_type`         | type of the algebra descriptor
`value_type`           | type $S$ of items to be stored in the container
`measured_type`        | type $T$ of measured values
`size_type`            | `size_t`

The only additional function that is required by the policy is a swap
operation.

Static members                                   | Description
-------------------------------------------------|------------------------------------
`void swap(measured_type& x, measured_type& y)`  | exchanges the values of `x` and `y`

### Example: trivial cached measurement

This trivial cached measurement is, by itself, completely inert: no
computation is required to maintain cached values and only a minimum
of space is required to store cached measurements on internal tree
nodes of the chunkedseq.

~~~~ {.cpp include="../include/cachedmeasure.example.trivial"}
~~~~

[source](../include/cachedmeasure.hpp)

### Example: weight-one (uniformly sized) items

In our implementation, we use this cached measurement policy to
maintain the size information of the container. The `size()` methods
of the different chunkedseq containers obtain the size information by
referencing values cached inside the tree by this policy.

~~~~ {.cpp include="../include/cachedmeasure.example.size"}
~~~~

[source](../include/cachedmeasure.hpp)

### Example: weighted items

Arbitrary weights can be maintained using a slight generalization of
the `size` measurement above.

~~~~ {.cpp include="../include/cachedmeasure.example.weight"}
~~~~

[source](../include/cachedmeasure.hpp)

### Example: combining cached measurements

Using the same combiner pattern we alredy presented for measures and
algebras, we can use the following template class to build
combinations of any two given cached-measurement policies.

~~~~ {.cpp include="../include/cachedmeasure.example.combiner"}
~~~~

[source](../include/cachedmeasure.hpp)

Splitting by predicate functions
--------------------------------

Logically, the split operation on a chunkedseq container divides the
underlying sequence into two pieces, leaving the first piece in the
container targeted by the split and moving the other piece to another
given container.
The position at which the split occurs is determined by a search
process that is guided by a *predicate function*.
What carries out the search process?
That job is the job of the internals of the chunkedseq class; the
client is responsible only to provide the predicate function that is
used by the search process.
Formally, a predicate function is simply a function $p$ which 
takes a measured value and returns either `true` or `false`:
$p(m) : T \rightarrow \mathtt{bool}$.

The search process guarantees that the position at which the split
occurs is the position $i$ in the target sequence, $s = [v_1,
\ldots, v_i, \ldots v_n]$, at which the value returned by
$p(M_{0,i}(s))$ first switches from false to true.
The first part of the split equals $[v_1, \ldots, v_{i-1}]$ and
the second $[v_i, \ldots, v_n]$.

### The predicate function descriptor

In our C++ package, we represent predicate functions as classes which
export the following public method.

Members                             | Description
------------------------------------|------------------------------------
`bool operator()(measured_type m)`  | returns $p(\mathtt{m})$

### Example: weighted splits

Let us first consider the small example which is given already for the
[weighted container](@ref weighted_container).  The action performed
by the example program is to divide a given sequence of strings so
that the first piece of the split contains approximately half of the
even-length strings and the second piece the second half.  In our
example code (see the page linked above), we assign to each item a
certain weight as follows: if the length of the given string is an
even number, return a 1; else, return a 0.

$m(str) : \mathtt{string} \rightarrow \mathtt{int} = 1 \, \mathrm{if}\, str.\mathtt{size()}\, \mathrm{is\, an\, even\, number\, and\, } 0 \, \mathrm{otherwise}$

Let $n$ denote the number of even-length strings in our source
sequence.  Then, the following predicate function delivers the exact
split that we want: $p(m) : int \rightarrow \mathtt{bool} = m \geq
n/2$.  Let $s$ denote the sequence of strings (i.e., `["Let's",
"divide", "this", "string", "into", "two", "pieces"]` that we want to
split.  The following table shows the logical states of the split
process.

+---------------+-------+--------+-------+--------+-------+------+--------+
| $i$           | 0     | 1      |2      |3       |4      |5     |6       |
+===============+=======+========+=======+========+=======+======+========+
| $v_i$         |`Let's`|`divide`|`this` |`string`| `into`|`two` |`pieces`|
+---------------+-------+--------+-------+--------+-------+------+--------+
|$m(v_i)$       |0      |1       |1      |1       |1      |0     |1       |
+---------------+-------+--------+-------+--------+-------+------+--------+
|$M_{0,i}(s)$   |0      |1       |2      |3       |4      |4     |5       |
+---------------+-------+--------+-------+--------+-------+------+--------+
|$p(M_{0,i}(s))$|`false`|`false` |`false`|`true`  |`true` |`true`|`true`  |
+---------------+-------+--------+-------+--------+-------+------+--------+

Remark:

> Even though the search process might look like a linear search, the
> process in fact takes just logarithmic time in the number of items in
> the sequence.  The logarithmic time bound is possible thanks to the
> fact that internal nodes of the chunkedseq tree (which is itself a
> tree whose height is logarithmic in the number of items) are annotated
> by partial sums of weights.

Example: using cached measurement to implement associative maps
---------------------------------------------------------------

Our final example combines all of the elements of cached measurement
to yield an asymptotically efficient implementation of associative
maps.
The idea behind the implementation is to represent the map internally
by a chunkedseq container of key-value pairs.
The key to efficiency is that the items in the chunkedseq are stored
in descending order.
When key-value pairs are logically added to the map, the key-value
pair is physically added to a position in the underlying sequence so
that the descending order is maintained.
The insertion and removal of key-value pairs is achieved by splitting
by a certain predicate function which we will see later.
At a high level, what is happening is a kind of binary search that
navigates the underlying chunkedseq structure, guided by
carefully chosen cached key values that annotate the interior nodes of
the chunkedseq.

Remark:

> We could have just as well maintain keys in ascending order.

### Optional values

Our implementation uses *optional values*, which are values that
logically either contain a value of a given type or contain nothing at
all.
The concept is similar to that of the null pointer, except that the
optional value applies to any given type, not just pointers.

~~~~ {.cpp include="../examples/map.example.option"}
~~~~

[source](../examples/map.hpp)

Observe that our class implements the "less-than" operator: `<`.
Our implementation of this operator lifts any implementation of the
same operator at the type `Item` to the space of our `option<Item>`:
that is, our operator treats the empty (i.e., nullary) optional value
as the smallest optional value.
Otherwise, our the comparison used by our operator is the implementation
already defined for the given type, `Item`, if such an implementation
is available.

### The measure descriptor

The type of value returned by the measure function (i.e.,
`measured_type`) is the optional key value, that is, a value of type
`option<key_type>`.
The measure function simply extracts the smallest key value from the
key-value pairs that it has at hand and packages them as an
optional key value.

~~~~ {.cpp include="../examples/map.example.get_key_of_last_item"}
~~~~

[source](../examples/map.hpp)

### The monoid descriptor

The monoid uses for its identity element the nullary optional key.
The combining operator takes two optional key values and of the two
returns either the smallest one or the nullary optional key value.

~~~~ {.cpp include="../examples/map.example.take_right_if_nonempty"}
~~~~

[source](../examples/map.hpp)

### The descriptor of the cached measurement policy

The cache measurement policy combines the measurement and monoid
descriptors in a straightforward fashion.

~~~~ {.cpp include="../examples/map.example.map_cache"}
~~~~

[source](../examples/map.hpp)

### The associative map

The associative map class maintains the underlying sorted sequence of
key-value pairs in the field called `seq`.
The method called `upper` is the method that is employed by the class
to maintain the invariant on the descending order of the keys.
This method returns either the position of the first key that is
greater than the given key, or the position of one past the end of the
sequence if the given key is the greatest key.

As is typical of STL style, the indexing operator is used by the
structure to handle both insertions and lookups.
The operator works by first searching in its underlying sequence for
the key referenced by its parameter; if found, the operator updates
the value component of the corresponding key-value pair.
Otherwise, the operator creates a new position in the sequence to put
the given key by calling the `insert` method of `seq` at the
appropriate position.

~~~~ {.cpp include="../examples/map.example.swap"}
~~~~

[source](../examples/map.hpp)


~~~~ {.cpp include="../examples/map.example.map"}
~~~~

[source](../examples/map.hpp)
