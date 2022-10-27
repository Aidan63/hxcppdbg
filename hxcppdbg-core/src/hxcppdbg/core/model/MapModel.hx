package hxcppdbg.core.model;

abstract class MapModel
{
    public abstract function count() : Int;

    public abstract function key(_index : Int) : ModelData;

    public abstract function value(_index : Int) : ModelData;

    public function iterator()
    {
        return new MapModelIterator(this);
    }

    public function keyValueIterator()
    {
        return new MapModelKeyValueIterator(this);
    }
}

private class MapModelIterator
{
    final model : MapModel;

    var index : Int;

    public function new(_model)
    {
        model = _model;
    }

    public function hasNext()
    {
        return index < model.count();
    }

    public function next()
    {
        return new Model(model.value(index), model.value(index++));
    }
}

private class MapModelKeyValueIterator
{
    final model : MapModel;

    var index : Int;

    public function new(_model)
    {
        model = _model;
    }

    public function hasNext()
    {
        return index < model.count();
    }

    public function next()
    {   
        return { key : model.key(index), value : model.value(index++) };
    }
}