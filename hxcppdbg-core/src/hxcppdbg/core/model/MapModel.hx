package hxcppdbg.core.model;

abstract class MapModel
{
    public abstract function count() : Int;

    public abstract function element(_index : Int) : Model;

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
        return model.element(index++);
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
        return { key : index, value : model.element(index++) };
    }
}