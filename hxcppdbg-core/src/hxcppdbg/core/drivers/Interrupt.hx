package hxcppdbg.core.drivers;

import haxe.ds.Option;

enum Interrupt
{
    ExceptionThrown(threadIndex : Option<Int>);
    BreakpointHit(threadIndex : Option<Int>, id : Option<Int>);
    Other;
}