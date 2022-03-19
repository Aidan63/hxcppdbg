package hxcppdbg.core.utils;

import sys.FileSystem;
import haxe.io.Path;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.PositionTools;

macro function xml(_lib : String) : Array<Field>
{
    final pos    = Context.currentPos();
    final info   = pos.getInfos();
    final source = Path.normalize(FileSystem.absolutePath(Path.directory(info.file)));

    final dirDefine = '<set name="${ _lib }Dir" value="$source"/>';
    final xmlImport = '<include name="${ Path.join([ source, '$_lib.xml' ]) }"/>';
    final expr      = macro $v{ '$dirDefine\n$xmlImport' };

    Context.getLocalClass().get().meta.add(':buildXml', [ expr ], pos);

    return Context.getBuildFields();
}