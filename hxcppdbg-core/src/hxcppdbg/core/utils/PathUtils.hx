package hxcppdbg.core.utils;

import hx.files.Path;

using StringTools;

function matches(_source : Path, _other : Path)
{
    return switch _source.isAbsolute
    {
        case true:
            switch _other.isAbsolute
            {
                case true:
                    _source.toString() == _other.toString();
                case false:
                    _source.toString().endsWith(_other.toString());
            }
        case false:
            switch _other.isAbsolute
            {
                case true:
                    _other.toString().endsWith(_source.toString());
                case false:
                    return _source.toString().endsWith(_other.toString()) || _other.toString().endsWith(_source.toString());
            }
    }
}