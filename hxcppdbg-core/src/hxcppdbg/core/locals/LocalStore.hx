package hxcppdbg.core.locals;

import haxe.Exception;
import haxe.ds.ReadOnlyArray;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.drivers.ILocalStore;
import hxcppdbg.core.sourcemap.Sourcemap;

using Lambda;

class LocalStore
{
    final sourcemap : ReadOnlyArray<NameMap>;

    final driver : ILocalStore;

    final cache : Map<String, ModelData>;

    public function new(_sourcemap, _driver)
    {
        sourcemap = _sourcemap;
        driver    = _driver;
        cache     = [];
    }

    public function getLocal(_name)
    {
        return switch cache[_name]
        {
            case null:
                switch sourcemap.find(v -> v.haxe == _name)
                {
                    case null:
                        Result.Error(new Exception('Failed to find mapping for local variable $_name'));
                    case found:
                        Result.Success(cache[found.cpp] = driver.local(found.cpp));
                }
            case cached:
                Result.Success(cached);
        }
    }

    public function getLocals()
    {
        return
            driver
                .locals()
                .filter(local -> sourcemap.exists(mapping -> mapping.cpp == local))
                .map(local -> sourcemap.find(mapping -> mapping.cpp == local).cpp);
    }
}