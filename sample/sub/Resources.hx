package sub;

class Resources {
	public function new() {}

	public function load(_name : String) {
		final typeid  = Math.random() * 1000;
		final resname = _name + typeid;

		trace(resname);

		return this;
	}

	public function subscribe(_onCompleted : Void->Void, v : Int) {
		trace('invoking callback $v');

		_onCompleted();
	}
}