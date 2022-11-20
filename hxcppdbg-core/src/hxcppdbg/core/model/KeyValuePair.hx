package hxcppdbg.core.model;

class KeyValuePair
{
    public final key : ModelData;

    public final value : ModelData;

    public function new(_key, _value)
    {
        key   = _key;
        value = _value;
    }
}