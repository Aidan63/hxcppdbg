package hxcppdbg.core.model;

abstract class ArrayModel
{
    abstract public function length() : Int;

    abstract public function at(_index : Int) : ModelData;

    public function iterator()
    {
        return new ArrayModelIterator(this);
    }

    public function keyValueIterator()
    {
        return new ArrayModelKeyValueIterator(this);
    }
}

private class ArrayModelIterator
{
    final model : ArrayModel;

    var index : Int;

    public function new(_model)
    {
        model = _model;
        index = 0;
    }

    public function hasNext()
    {
        return index < model.length();
    }

    public function next()
    {
        return model.at(index++);
    }
}

private class ArrayModelKeyValueIterator
{
    final model : ArrayModel;

    var index : Int;

    public function new(_model)
    {
        model = _model;
        index = 0;
    }

    public function hasNext()
    {
        return index < model.length();
    }

    public function next()
    {
        return { key : index, value : model.at(index++) };
    }
}