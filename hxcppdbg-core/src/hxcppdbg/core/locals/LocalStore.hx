package hxcppdbg.core.locals;

import haxe.Exception;
import haxe.ds.ReadOnlyArray;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Keyable;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.sourcemap.Sourcemap;

using Lambda;

class LocalStore extends Keyable<String>
{
    final sourcemap : ReadOnlyArray<NameMap>;

    public function new(_model, _sourcemap)
    {
        super(_model);

        sourcemap = _sourcemap;
    }

	public override function get(_key : String) : Result<ModelData, Exception>
    {
		return switch sourcemap.find(map -> map.haxe == _key)
        {
            case null:
                Result.Error(new Exception('Unable to find variable mapping for $_key'));
            case mapping:
                super.get(mapping.cpp);
        }
	}
}