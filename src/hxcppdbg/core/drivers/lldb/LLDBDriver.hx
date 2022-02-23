package hxcppdbg.core.drivers.lldb;

class LLDBDriver extends Driver
{
    final objects : LLDBObjects;

    final process : LLDBProcess;

    public function new(_file) {
        LLDBBoot.boot();

        objects     = LLDBObjects.createFromFile(_file);
        process     = objects.launch();
        breakpoints = new LLDBBreakpoints(objects);
    }

	public function start()
    {
        process.start(Sys.getCwd());
    }

	public function stop()
    {
        //
    }

    public function pause()
    {
        //
    }

	public function resume()
    {
        process.resume();
    }
}

class LLDBBreakpoints implements IBreakpoints
{
    final object : LLDBObjects;

    public function new(_object)
    {
        object = _object;
    }

	public function create(_file : String, _line : Int)
    {
		return object.setBreakpoint(_file, _line);
	}

	public function remove(_id : Int)
    {
        return object.removeBreakpoint(_id);
    }
}