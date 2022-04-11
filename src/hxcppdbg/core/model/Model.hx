package hxcppdbg.core.model;

class Model
{
    public final name : String;

    public final data : ModelData;

    public function new(_name, _data)
    {
        name = _name;
        data = _data;
    }
}
