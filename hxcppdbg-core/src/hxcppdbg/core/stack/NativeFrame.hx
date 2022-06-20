package hxcppdbg.core.stack;

/**
 * Driver agnostic native frame representation.
 */
class NativeFrame
{
    /**
     * Absolute path to the file which contains this frames function.
     */
    public final file : String;

    /**
     * Fully qualified type path of the c++ function of this frame.
     * Any driver specific notation will have been stripped out, arguments will not be included.
     * 
     * `some::namespace::MyClass::myFunc`
     */
    public final func : String;

    /**
     * Line in the file this frame is at.
     */
    public final line : Int;

    public function new(_file, _func, _line)
    {
        file = _file;
        func = _func;
        line = _line;
    }
}