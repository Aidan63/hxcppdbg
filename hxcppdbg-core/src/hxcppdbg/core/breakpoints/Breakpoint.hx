package hxcppdbg.core.breakpoints;

import haxe.ds.ReadOnlyArray;
import hxcppdbg.core.ds.Path;

class Breakpoint
{
    /**
     * Unique ID of this breakpoint.
     */
    public final id : Int;

    /**
     * The haxe file this breakpoint was placed in.
     */
    public final file : Path;

    /**
     * The line this breakpoint was placed at.
     */
    public final line : Int;

    /**
     * The character offset along the line it was placed at.
     */
    public final char : Int;

    /**
     * Array native breakpoint IDs which were created due to this breakpoint.
     */
    public final native : ReadOnlyArray<Int>;

    public function new (_id, _file, _line, _char, _native)
    {
        id     = _id;
        file   = _file;
        line   = _line;
        char   = _char;
        native = _native;
    }
}