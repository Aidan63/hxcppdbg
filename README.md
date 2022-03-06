Experimental debugger for hxcpp programs utilising LLDB or the  windows debugger engine with sourcemaps generated by the haxe compiler. By using existing cpp debuggers we can catch and surface many errors which the existing hxcpp debugger can't.

One goal is to support "mixed mode debugging" where you can step into the cpp code invoked by extern functions, similar to how c#, cpp, and python can all be debugged under one session in visual studio. This should make debugging any extern glue code much easier.