package hxcppdbg.core.stack;

import hxcppdbg.core.stack.HaxeFrame;
import hxcppdbg.core.stack.NativeFrame;

enum StackFrame
{
    Haxe(haxe : HaxeFrame, native : NativeFrame);
    Native(frame : NativeFrame);
}