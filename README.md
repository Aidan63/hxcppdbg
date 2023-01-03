Experimental debugger for hxcpp programs utilising LLDB or the  windows debugger engine with sourcemaps generated by the haxe compiler. By using existing cpp debuggers we can catch and surface many errors which the existing hxcpp debugger can't.

One goal is to support "mixed mode debugging" where you can step into the cpp code invoked by extern functions, similar to how c#, cpp, and python can all be debugged under one session in visual studio. This should make debugging any extern glue code much easier.

![img](https://raw.githubusercontent.com/Aidan63/hxcppdbg/master/img.jpg)

https://blog.aidanlee.uk/hxcppdbg-intro/

# Features

## breakpoints

- [x] create breakpoints by file, line, and character
- [ ] create breakpoints by function
- [x] composite breakpoints (multiple native breakpoints under one haxe breakpoint, for optimisations like unrolled loops)
- [ ] hscript conditional breakpoints

## callstack

- [x] map cpp frames back to haxe frames
- [x] allow displaying native frames as well as haxe frames

## exceptions

- [x] break when exceptions are thrown
- [ ] break when exceptions are caught
- [ ] filter which exceptions to break on

## stepping

- [x] step in
- [x] step out
- [x] step over

## data model

- [x] ints
- [x] floats
- [x] strings
- [x] data structures
    - [x] array
    - [x] virtual array
    - [x] map
- [x] interop types
    - [x] pointers
    - [x] structs
    - [x] references
- [x] object ptr
- [x] anon objects
- [x] dynamic
- [x] enums
- [x] classes

## expressions

- [x] hscript evaluator

## drivers

- [x] dbgeng.dll and dbgmodel.dll for windows
- [x] lldb for mac and linux work in progress (data model is incomplete)

## usage

- [x] cli
- [x] debug adapter protocol