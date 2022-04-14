package hxcppdbg.core.model;

class Model
{
    public final key : ModelData;

    public final data : ModelData;

    public function new(_key, _data)
    {
        key  = _key;
        data = _data;
    }
}
